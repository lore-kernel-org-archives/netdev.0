From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH] net: fec: stop the "rcv is not +last, " error messages
Date: Wed, 30 Mar 2016 10:04:20 -0700
Message-ID: <56FC0714.6060607@boundarydevices.com>
References: <56FB46EA.7050401@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Greg Ungerer <gerg@uclinux.org>, Zhi Li <lznuaa@gmail.com>,
	Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33468 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147AbcC3REX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 13:04:23 -0400
Received: by mail-pf0-f177.google.com with SMTP id 4so47658126pfd.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 10:04:22 -0700 (PDT)
In-Reply-To: <56FB46EA.7050401@uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/29/2016 8:24 PM, Greg Ungerer wrote:
> Hi Troy,
> 
> Commit 55cd48c8 ('net: fec: stop the "rcv is not +last, " error
> messages') adds a write to a register that is not present in all
> implementations of the FEC hardware module. None of the ColdFire
> SoC parts with the FEC module have the FTRL (0x1b0) register.
> 
> Does this need a quirk flag to key access to this register of?
> Or can you piggyback on the FEC_QUIRK_HAS_RACC flag?
> 
> Regards
> Greg

I'm no expert on what hardware has which registers, but piggybacking
works for all the processors that I use. Let's see what Freescale
says, but would you like to submit a patch to move it inside the quirk's
"if", or do you want me to do it?
