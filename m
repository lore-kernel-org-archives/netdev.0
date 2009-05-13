From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: via velocity trivial patch
Date: Thu, 14 May 2009 00:32:49 +0200
Message-ID: <20090513223249.GB4118@electric-eye.fr.zoreil.com>
References: <49F1A05A.8070802@podgorny.cz> <4A01FBF6.1090001@podgorny.cz> <20090507.150213.192379856.davem@davemloft.net> <4A04184E.5040507@podgorny.cz> <20090508192948.GA19016@electric-eye.fr.zoreil.com> <4A0AC537.70605@podgorny.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Radek Podgorny <radek@podgorny.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52783 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758876AbZEMWbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 18:31:46 -0400
Content-Disposition: inline
In-Reply-To: <4A0AC537.70605@podgorny.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radek Podgorny <radek@podgorny.cz> :
> -----BEGIN PGP SIGNED MESSAGE-----
[...]
> so I've tried to study the source a bit more and don't really get some things.
> Why is there a mac_write_isr() in the IRQ handling routine? Isn't ISR supposed
> to be read-only? Even if not, why does it write the exact same value as it has
> read just moments ago?

It clears the bits.

-- 
Ueimor
