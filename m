From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 2/2] macvtap: fix uninitialized return
 value macvtap_ioctl_set_queue()
Date: Thu, 13 Jun 2013 01:23:36 -0700 (PDT)
Message-ID: <20130613.012336.1431021696375181869.davem@davemloft.net>
References: <1371104616-18319-1-git-send-email-jasowang@redhat.com>
	<1371104616-18319-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371104616-18319-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 13 Jun 2013 14:23:36 +0800

> Return -EINVAL on illegal flag instead of uninitialized value. This fixes the
> kbuild test warning.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
