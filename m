From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: about tx_queue_len for phonet driver
Date: Thu, 12 Jan 2012 11:57:53 +0100
Message-ID: <1326365873.2950.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <81C3A93C17462B4BBD7E272753C105791FB10F9968@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
To: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38737 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab2ALK55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 05:57:57 -0500
Received: by qadc10 with SMTP id c10so4105qad.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 02:57:56 -0800 (PST)
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791FB10F9968@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 janvier 2012 =C3=A0 11:45 +0100, Hemant-vilas RAMDASI a =C3=
=A9crit :
> Hi,
>=20
> Can anyone guide me about when should a network driver set
> tx_queue_len to 0?
> We are facing a network congestion issue with phonet packets where on=
e
> of the control message packet is dropped because of congestion. In ou=
r
> phonet network driver the tx_queue_len is set to 3 (taken from
> usb-phonet mostly). If phonet cannot handle packet-drop (for pipe
> messages), then should network driver always set tx_queue_len as 0?

0 is usually used by virtual devices, since real device has a queue.

In your case, I would rather increase a bit the tx_queue_len

I noticed in the past 3 is the default for ppp, and we can indeed have
drops because 3 is too small for current usages.
