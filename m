From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next 17/17] tcp: get rid of two unnecessary u16s in TCP skb flags copying
Date: Sun, 01 Mar 2009 03:39:02 +0100
Message-ID: <87ocwm0xx5.fsf@basil.nowhere.org>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831223-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322833023-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832837-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37673 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756335AbZCACk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 21:40:56 -0500
In-Reply-To: <12358322832837-git-send-email-ilpo.jarvinen@helsinki.fi> (Ilpo
 =?iso-8859-1?Q?J=E4rvinen's?= message of "Sat, 28 Feb 2009 16:44:42 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> writes:

> From: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
>
> I guess these fields were one day 16-bit in the struct but
> nowadays they're just using 8 bits anyway.
>
> This is just a precaution, didn't result any change in my
> case but who knows what all those varying gcc versions &
> options do. I've been told that 16-bit is not so nice with
> some cpus.

Typically when 16bit is not nice, 8bit isn't nice either.
=46or general flags the most save in terms of uniform performance
is "int"

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
