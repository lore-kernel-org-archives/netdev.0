From: Eric Dumazet <edumazet@google.com>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Mon, 19 Jan 2015 14:38:47 -0800
Message-ID: <CANn89iLpgUEuHQvyJHR8g3q62-Hi-XfYKeVpLvG__UQLrqR5Bg@mail.gmail.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	<20141201102522.GA16579@gondor.apana.org.au>
	<20141231133923.GA30248@gondor.apana.org.au>
	<2797327.cCdE9QefP4@storm>
	<CANn89i+U-PFbuUrp08s3Ec8BmjPFq1zj8Aj2=vPVO4-iiLkTuw@mail.gmail.com>
	<20150119223635.GA8735@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:62545 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbbASWis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 17:38:48 -0500
Received: by mail-qg0-f43.google.com with SMTP id e89so7842308qgf.2
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 14:38:47 -0800 (PST)
In-Reply-To: <20150119223635.GA8735@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 2:36 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Jan 19, 2015 at 09:19:48AM -0800, Eric Dumazet wrote:
>> Zero sized packets are valid, just take a look at tcpdump ;)
>
> But zero-sized packets in the send queue are not valid and will
> not ever be cleaned, which is what triggered the original bug.

SYN and FIN packets are in the send queue.

They are valid and might have a zero size.
