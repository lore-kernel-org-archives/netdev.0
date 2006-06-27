From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/3] natsemi: Add quirks for Aculab E1/T1 PMXc cPCI carrier
 cards
Date: Mon, 26 Jun 2006 23:49:22 -0400
Message-ID: <44A0AAC2.5060509@garzik.org>
References: <200606250844.k5P8iZkg020788@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, broonie@sirena.org.uk, jgarzik@pobox.com,
	thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:26585 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030622AbWF0Dt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 23:49:28 -0400
To: akpm@osdl.org
In-Reply-To: <200606250844.k5P8iZkg020788@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Mark Brown <broonie@sirena.org.uk>
> 
> Aculab E1/T1 PMXc cPCI carrier card cards present a natsemi on the cPCI bus
> wired up in a non-standard fashion.  This patch provides support in the
> natsemi driver for these cards by implementing a quirk mechanism and using
> that to configure appropriate settings for the card: forcing 100M full duplex,
> having a large EEPROM and using the MII port while ignoring PHYs.
> 
> Signed-off-by: Mark Brown <broonie@sirena.org.uk>
> Cc: Tim Hockin <thockin@hockin.org>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> 
> [akpm: this is a previously-nacked patch, but the problem is real]
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  drivers/net/natsemi.c   |   94 ++++++++++++++++++++++++--------------
>  include/linux/pci_ids.h |    3 +
>  2 files changed, 63 insertions(+), 34 deletions(-)

I checked in a couple patches in preparation for merging this.  Please 
rediff and resend, and I'll apply.

	Jeff



