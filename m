From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Add support for running the Marvell m88e1111 PHY in RGMII mode
Date: Thu, 12 Apr 2007 02:43:15 +0200
Message-ID: <20070412004315.GD15021@xi.wantstofly.org>
References: <20070410165723.472fdc69.kim.phillips@freescale.com> <20070411010158.GB9526@xi.wantstofly.org> <20070411163649.2d055676.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:54306 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbXDLAnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 20:43:19 -0400
Content-Disposition: inline
In-Reply-To: <20070411163649.2d055676.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2007 at 04:36:49PM -0500, Kim Phillips wrote:

> > On Tue, Apr 10, 2007 at 04:57:23PM -0500, Kim Phillips wrote:
> > 
> > > also adds RX & TX delay bits to help boards with clock skew
> > > problems.
> > 
> <snip>
> > 
> > > [...]
> > > +
> > > +		temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
> > 
> > Enabling this unconditionally is just wrong.
> 
> I agree.  There needs to be a way for the platform code to
> communicate board specific quirkiness to the phylib

(I'm not sure whether it's really a quirk, as the RGMII spec allows
both modes.)


> (I just haven't figured out how to yet).

Maybe offer separate RGMII and RGMII-ID[*] mode choices?


[*] RGMII with Internal Delay (RGMII specification nomenclature)
