From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Mon, 14 May 2007 12:02:06 -0700
Message-ID: <20070514120206.5181839e@freepuppy>
References: <20070430142349.79754c1b@freekitty>
	<46374784.7010401@gentoo.org>
	<20070510090010.4c6b8589@freepuppy>
	<464734F1.2020103@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	stable@kernel.org, Francois SIMOND <curio@free.fr>
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.linux-foundation.org ([207.189.120.12]:35186 "EHLO
	smtp.osdl.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754883AbXENTEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 15:04:35 -0400
In-Reply-To: <464734F1.2020103@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 May 2007 11:55:29 -0400
Daniel Drake <dsd@gentoo.org> wrote:

> Stephen Hemminger wrote:
> > I can use DMI to narrow down to one motherboard. 
> > Or just let everything through and let user's discover what's unstable, it fails
> > relatively quickly.
> > 
> > Could you please get full PCI info lspci -vvxxx for working/non-working 88e8056 (Yukon EC-U)
> > systems? It might be some PCI Express setup by the BIOS, but so far haven't
> > found any difference that mattered.
> 
> I haven't seen any reports of systems affected by the corruption issue 
> so I can't provide any data there.
> 
> Here is the full lspci output for a few systems with 88E8056 devices 
> that work fine:
> 
> Gigabyte P965-S3
> http://bugs.gentoo.org/attachment.cgi?id=118827&action=view
> 
> Gigabyte P965-S3 (from another user)
> http://bugs.gentoo.org/attachment.cgi?id=118848&action=view
> 
> Asus P5B deluxe
> http://bugs.gentoo.org/attachment.cgi?id=119038&action=view
> 
> 
> Daniel

It looks like these users aren't using MSI?

Also, there maybe some correlation of the problem with IDE AHCI mode.
I am using WD Raptor 10K driver with AHCI, that does Native Command Queuing,
could be some weird IDE interaction. If I turn off AHCI, it works better
(still fails but differently).  

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
