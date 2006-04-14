From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: [PATCH] bcm43xx: iw_priv_args names should be <16 characters
Date: Fri, 14 Apr 2006 11:35:03 +0200
Message-ID: <20060414093503.GF20839@harddisk-recovery.com>
References: <20060413130227.GD20839@harddisk-recovery.nl> <20060413102919.5e0bdb2e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:43081 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S965119AbWDNJfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 05:35:04 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060413102919.5e0bdb2e@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 10:29:19AM -0700, Stephen Hemminger wrote:
> On Thu, 13 Apr 2006 15:02:27 +0200
> Erik Mouw <erik@harddisk-recovery.com> wrote:
> 
> > The room for the names in bcm43xx_priv_wx_args[] are IFNAMSIZ long and
> > IFNAMSIZ is defined as 16, so the names in bcm43xx_priv_wx_args should
> > be 15 characters (16 including the trailing \0). This patch fixes that
> > for the "set_shortpreambl", "get_shortpreambl", "set_swencryption", and
> > "get_swencryption" private calls. Patch is against 2.6.17-rc1.
> > 
> > Signed-off-by: Erik Mouw <erik@harddisk-recovery.com>
> 
> Shouldn't compiler have gagged on this?

Apparently not. At least the compiler I use doesn't warn about it (gcc
version 3.3.5 (Debian 1:3.3.5-13)).

Linus, this might be be something for sparse to check:

  struct mystruct {
	char name[16];
  };

  mystruct ms = { .name = "muchlongerthan16characters" };


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
