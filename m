From: Sven Luther <sven@powerlinux.fr>
Subject: Re: [RFC PATCH v0.2] net driver: mpc52xx fec
Date: Mon, 17 Sep 2007 11:53:34 +0200
Message-ID: <20070917095334.GA4546@powerlinux.fr>
References: <20070810095153.GC13994@moe.telargo.com> <20070902074143.GB2642@nd47.coderock.org> <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com> <20070915121444.GA19857@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Likely <grant.likely@secretlab.ca>, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org
To: Domen Puncer <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archon.plz.fr ([194.50.78.210]:48053 "EHLO archon.plz.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193AbXIQKVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 06:21:14 -0400
Content-Disposition: inline
In-Reply-To: <20070915121444.GA19857@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 15, 2007 at 02:14:44PM +0200, Domen Puncer wrote:
> Updated and split version at:
> http://coderock.org/tmp/fec-v3rc1/
> 
> I'll repost to lists once I run-test them.

When applying those patches, the build did die with :


  ERROR: "phy_mii_ioctl" [drivers/net/fec_mpc52xx/fec_mpc52xx.ko] undefined!

Apparently, phy_mii_ioctl is not an exported symbol.

Domen, did you maybe forget a little snipplet when you cut the patches
in different pieces ? Or did i mess up applying them ?

Friendly,

Sven Luther

