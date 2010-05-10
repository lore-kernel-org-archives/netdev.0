From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Mon, 10 May 2010 17:18:13 +0200
Message-ID: <1273504693.2221.17.camel@edumazet-laptop>
References: <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273147586.2357.63.camel@edumazet-laptop>
	 <20100506.220443.135536330.davem@davemloft.net>
	 <1273210329.2222.42.camel@edumazet-laptop>
	 <20100507101451.1b4286b7@nehalam>
	 <1273252893.2261.84.camel@edumazet-laptop>
	 <20100507103639.4f1a51fa@nehalam>
	 <1273268446.2325.53.camel@edumazet-laptop>
	 <D1C2B1EC-ABE8-4D87-9227-6D0F1C1C8B77@guavus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	"<bhaskie@gmail.com>" <bhaskie@gmail.com>,
	"<bhutchings@solarflare.com>" <bhutchings@solarflare.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>
To: Bijay Singh <Bijay.Singh@guavus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54533 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796Ab0EJPSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 11:18:20 -0400
Received: by fxm7 with SMTP id 7so190058fxm.19
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 08:18:18 -0700 (PDT)
In-Reply-To: <D1C2B1EC-ABE8-4D87-9227-6D0F1C1C8B77@guavus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 mai 2010 =C3=A0 14:55 +0000, Bijay Singh a =C3=A9crit :
> Hi,
> I had noticed the corruption in the context and actually did what is =
mentioned.
>=20
> I allocated the context on the stack and plugged in the md5.c functio=
ns. I was able to temporarily solve the problem, all this before I got =
a response on this thread.
>=20
> But now I have seeing another problem, when i change the MTU on the i=
nterface from 1500 to 4470 none of the message from the peer get thru a=
nd I get hash failed message. I am wondering if this is another bug get=
ting hit in this scenario.

Thats very fine, but you mix very different problems.

Step by step resolution is required, and clean patches too, because
plugging md5.c functions is not an option for stable series :)

Obviously, nobody seriously used TCP-MD5 on linux, but you...



