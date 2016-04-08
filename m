From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] ipv6, token: allow for clearing the current device token
Date: Fri, 08 Apr 2016 16:18:29 +0200
Message-ID: <878u0otc96.fsf@nemi.mork.no>
References: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	robbat2@gentoo.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45659 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbcDHOTO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 10:19:14 -0400
In-Reply-To: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
	(Daniel Borkmann's message of "Fri, 8 Apr 2016 15:55:00 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <daniel@iogearbox.net> writes:

> =20
>  	if (!token)
>  		return -EINVAL;
> -	if (ipv6_addr_any(token))
> -		return -EINVAL;
>  	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
>  		return -EINVAL;

Not directly related to the patch in question.  It just made me aware o=
f
this restriction...

I realize that I'm a few years late here, but what's with the IFF_NOARP=
?
Is that just because we can't do DAD for the token based addresses?  Ho=
w
is that different from manually configuring the whole address?



Bj=C3=B8rn
