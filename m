From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/13]bnx2x: Adding bnx2x_link
Date: Sun, 1 Jun 2008 23:37:49 +0100
Message-ID: <20080601223748.GI30769@solarflare.com>
References: <1212333127.6967.121.camel@ubuntu804desktop.localdomain> <87tzgc283g.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eilong@broadcom.com, netdev <netdev@vger.kernel.org>,
	jeff@garzik.org, davem@davemloft.net,
	Eliezer Tamir <eliezert@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:39583 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752204AbYFAWiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 18:38:10 -0400
Content-Disposition: inline
In-Reply-To: <87tzgc283g.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
[...]
> > +/* Programs an image to DSP's flash via the SPI port*/
> > +static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
> > +				     u8 ext_phy_addr,
> > +				     char data[], u32 size)
> 
> Hmm does the driver really need a flash updater as standard
> functionality? That could be a separate program.
[...]

It shouldn't need to do this.  The boot loader in the SFX7101 allows
flash update through MDIO if the appropriate pin is pulled low at
reset (see phy_flash_cfg option in the sfc driver).  Of course that
doesn't help if the board doesn't allow this to be controlled...

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
