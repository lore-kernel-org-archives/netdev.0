From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CONFIG_INET depend on CONFIG_SYSCTL
Date: Tue, 12 Jun 2007 23:05:45 -0700 (PDT)
Message-ID: <20070612.230545.104645806.davem@davemloft.net>
References: <m2sl8xfwq8.wl%ysato@users.sourceforge.jp>
	<20070612.010855.51301101.davem@davemloft.net>
	<m2abv41jkb.wl%ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ysato@users.sourceforge.jp
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756701AbXFMGFl@vger.kernel.org>
In-Reply-To: <m2abv41jkb.wl%ysato@users.sourceforge.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshinori Sato <ysato@users.sourceforge.jp>
Date: Wed, 13 Jun 2007 14:59:16 +0900

> At Tue, 12 Jun 2007 01:08:55 -0700 (PDT),
> David Miller wrote:
>  
> > 2) It is much better to add the appropriate CONFIG_SYSCTL
> >    ifdefs to the INET code than to force it on for everyone.
> 
> It examined that, but many corrections become necessary.

I understand, but embedded people will not be happy that
SYSFS is a requirement for IPV4 networking.  Every little
bit of space savings matters for them.
