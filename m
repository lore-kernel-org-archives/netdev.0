From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [PATCH] set NLM_F_MULTI in answer of RTM_GETADDR dump
 answer
Date: Sat, 9 Aug 2003 20:47:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809204728.03100f55.davem@redhat.com>
References: <20030809011153.46a99ef2.davem@redhat.com>
	<200308100303.HAA20709@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200308100303.HAA20709@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 10 Aug 2003 07:03:48 +0400 (MSD)
kuznet@ms2.inr.ac.ru wrote:

> > After sending RTM_GETADDR dump request to netlink socket, received multipart
> > answer does not have NLM_F_MULTI set on each message. This patch fix that.
> 
> OK.
> 
> Actually, this flag was never used because of its redundancy
> it is not the only place where it is not set.

Ok, I applied the patch.

Thanks for the review Alexey.
