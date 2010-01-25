From: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Mon, 25 Jan 2010 19:14:08 +0100
Message-ID: <4B5DDF70.8010709@LiPPERTEmbedded.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tristram Ha <Tristram.Ha@Micrel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lippert-at.com ([62.80.22.186]:19374 "EHLO
	domex.lippertembedded.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751433Ab0AYS2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 13:28:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ksz884x.c: read_other_addr(struct ksz_hw *hw)

"u16 data[3]" instead of "u16 data[4]" is sufficient.

And when checking if the 2nd MAC is actually stored in EEPROM or if it's only
all empty (only FF) you overlooked that you're doing it wordwise, so you'll
have to check "data[0] != 0xffff" instead of "data[0] != 0xff".

Best regards,
Jens Rottmann

