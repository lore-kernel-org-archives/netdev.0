From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Sun, 13 May 2007 11:55:29 -0400
Message-ID: <464734F1.2020103@gentoo.org>
References: <20070430142349.79754c1b@freekitty>	<46374784.7010401@gentoo.org> <20070510090010.4c6b8589@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	stable@kernel.org, Francois SIMOND <curio@free.fr>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:59878 "EHLO
	smtp151.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757745AbXEMP4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2007 11:56:30 -0400
In-Reply-To: <20070510090010.4c6b8589@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I can use DMI to narrow down to one motherboard. 
> Or just let everything through and let user's discover what's unstable, it fails
> relatively quickly.
> 
> Could you please get full PCI info lspci -vvxxx for working/non-working 88e8056 (Yukon EC-U)
> systems? It might be some PCI Express setup by the BIOS, but so far haven't
> found any difference that mattered.

I haven't seen any reports of systems affected by the corruption issue 
so I can't provide any data there.

Here is the full lspci output for a few systems with 88E8056 devices 
that work fine:

Gigabyte P965-S3
http://bugs.gentoo.org/attachment.cgi?id=118827&action=view

Gigabyte P965-S3 (from another user)
http://bugs.gentoo.org/attachment.cgi?id=118848&action=view

Asus P5B deluxe
http://bugs.gentoo.org/attachment.cgi?id=119038&action=view


Daniel
