From: Greg Ungerer <gerg@uclinux.org>
Subject: Re: [PATCH] net: fec: stop the "rcv is not +last, " error messages
Date: Wed, 30 Mar 2016 13:24:26 +1000
Message-ID: <56FB46EA.7050401@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out7.external.iinet.net.au ([203.59.1.107]:35234
	"EHLO icp-osb-irony-out7.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754008AbcC3Ddn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 23:33:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Troy,

Commit 55cd48c8 ('net: fec: stop the "rcv is not +last, " error
messages') adds a write to a register that is not present in all
implementations of the FEC hardware module. None of the ColdFire
SoC parts with the FEC module have the FTRL (0x1b0) register.

Does this need a quirk flag to key access to this register of?
Or can you piggyback on the FEC_QUIRK_HAS_RACC flag?

Regards
Greg
