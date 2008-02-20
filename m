From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 1/8] [NET]: uninline skb_put, de-bloats a lot
Date: Wed, 20 Feb 2008 14:54:55 +0100
Message-ID: <47BC312F.2060905@trash.net>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:43935 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756608AbYBTNzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:55:13 -0500
In-Reply-To: <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> ~500 files changed
> ...
> kernel/uninlined.c:
>   skb_put                       | +104
>  1 function changed, 104 bytes added, diff: +104
>=20
> vmlinux.o:
>  869 functions changed, 198 bytes added, 111003 bytes removed, diff: =
-110805
>=20
> This change is INCOMPLETE, I think that the call to current_text_addr=
()
> should be rethought but I don't have a clue how to do that.


I guess __builtin_return_address(0) would work.
