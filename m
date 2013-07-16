From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] macvtap: fix the missing ret value of
 TUNSETQUEUE
Date: Tue, 16 Jul 2013 13:03:29 -0700 (PDT)
Message-ID: <20130716.130329.1709960351198536948.davem@davemloft.net>
References: <1373952994-7252-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vyasevic@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373952994-7252-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 16 Jul 2013 13:36:33 +0800

> Commit 441ac0fcaadc76ad09771812382345001dd2b813
> (macvtap: Convert to using rtnl lock) forget to return what
> macvtap_ioctl_set_queue() returns to its caller. This may break multiqueue API
> by always falling through to TUNGETFEATURES.
> 
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
