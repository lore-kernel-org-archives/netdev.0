From: Domen Puncer <domen@coderock.org>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Tue, 18 Sep 2007 17:16:22 +0200
Message-ID: <20070918151622.GD32628@nd47.coderock.org>
References: <20070810095153.GC13994@moe.telargo.com> <20070902074143.GB2642@nd47.coderock.org> <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com> <20070915121444.GA19857@nd47.coderock.org> <20070917095334.GA4546@powerlinux.fr> <20070917202140.GB2642@nd47.coderock.org> <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org,
	sven@powerlinux.fr
To: Jon Smirl <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kukmak.uni-mb.si ([164.8.100.3]:50512 "EHLO kukmak.uni-mb.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574AbXIRPQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 11:16:25 -0400
Content-Disposition: inline
In-Reply-To: <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(I edited Cc: -jeff, +sven, hope you don't mind)

On 17/09/07 18:08 -0400, Jon Smirl wrote:
> On 9/17/07, Domen Puncer <domen@coderock.org> wrote:
> > Export phy_mii_ioctl, so network drivers can use it when built
> > as modules too.
> 
> Domen, do you want to collect all of these changes for MPC5200 FEC in
> to a single patch series? The code is getting scattered around, I'll
> check it over to make sure it is all working. I have these patches
> applied individually and they all work.
> 
> It builds on this series:
> [PATCH 0/7] MPC52xx Bestcomm submission for 2.6.24
> 
> If you can put this together is a clean series, I should be able to
> layer support for the Phytec pcm030 on top of it.
> 
> It would be these three combined...
> 
> http://coderock.org/tmp/fec-v3rc1/

http://coderock.org/tmp/fec-v3rc2/
 export_phy_mii_ioctl    
 fec_driver-bestcomm     
 fec_driver-dts          
 fec_driver-fec
 fec_driver-phy     

Built (on top of 7 bestcomm patches) and ran it built-in and as module
on Efika.

Order of applying only matters for phy part, which has to be after
the fec driver.


More testing and getting it to work properly on Phytec pcm030 would
be great.



	Domen
