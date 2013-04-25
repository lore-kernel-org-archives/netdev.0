From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tuntap: correct the return value in tun_set_iff()
Date: Thu, 25 Apr 2013 01:49:25 -0400 (EDT)
Message-ID: <20130425.014925.207045396378265668.davem@davemloft.net>
References: <1366699239-6866-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hkchu@google.com, weiyj.lk@gmail.com, edumazet@google.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366699239-6866-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 23 Apr 2013 14:40:39 +0800

> commit (3be8fbab tuntap: fix error return code in tun_set_iff()) breaks the
> creation of multiqueue tuntap since it forbids to create more than one queues
> for a multiqueue tuntap device. We need return 0 instead -EBUSY here since we
> don't want to re-initialize the device when one or more queues has been already
> attached. Add a comment and correct the return value to zero.
> 
> Reported-by: Jerry Chu <hkchu@google.com>
> Cc: Jerry Chu <hkchu@google.com>
> Cc: Wei Yongjun <weiyj.lk@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
