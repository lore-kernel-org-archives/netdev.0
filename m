From: Tom Herbert <therbert@google.com>
Subject: Re: RPS and forwarding
Date: Sun, 25 Apr 2010 22:00:09 -0700
Message-ID: <r2n65634d661004252200x4e7a49f1h181cdd69b3e4ebc0@mail.gmail.com>
References: <20100426022415.GA20323@gondor.apana.org.au>
	 <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
	 <20100426045316.GA21810@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:39352 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab0DZFAO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 01:00:14 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [10.3.21.13])
	by smtp-out.google.com with ESMTP id o3Q50Cbi004553
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 07:00:12 +0200
Received: from pzk40 (pzk40.prod.google.com [10.243.19.168])
	by hpaq13.eem.corp.google.com with ESMTP id o3Q50ApR024295
	for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 07:00:11 +0200
Received: by pzk40 with SMTP id 40so7873997pzk.23
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 22:00:09 -0700 (PDT)
In-Reply-To: <20100426045316.GA21810@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Right. =A0The problem is that if you run a distribution kernel on
> a router with CONFIG_RPS (and hence RFS) enabled, you may suddenly
> start seeing packet reordering on forwarded traffic due to the
> presence of local traffic.
>
> Can we perhaps add a run-time toggle to disable RFS?
>
RFS is not on at run-time by default.  The number of entries in the
global_rps_sock table needs to be set in sysctl, and the number of
entries in rps_dev_flow_table needs to be set per RX queue in sysfs.
You can turn it on for some devices, but not others if that helps.

> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
