From: Tom Herbert <therbert@google.com>
Subject: Re: RPS and forwarding
Date: Sun, 25 Apr 2010 21:44:05 -0700
Message-ID: <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
References: <20100426022415.GA20323@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:36782 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859Ab0DZEoK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 00:44:10 -0400
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o3Q4i7mN029696
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 06:44:07 +0200
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by wpaz13.hot.corp.google.com with ESMTP id o3Q4i5fC013602
	for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 21:44:06 -0700
Received: by pwj5 with SMTP id 5so7044689pwj.34
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 21:44:05 -0700 (PDT)
In-Reply-To: <20100426022415.GA20323@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Apart from not using RPS on routers, I suppose people doing
> forwarding will simply have to maintain a constant RPS table,
> and forgo its local redirection capabilities.
>

I think you'd want RPS on router (steering packets using hash and CPU
mask).  Most of your concerns are about RFS (steering by flows), which
is probably more appropriate for a server.

Tom

> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
