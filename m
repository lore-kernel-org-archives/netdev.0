From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Tue, 28 Feb 2012 14:05:58 -0500 (EST)
Message-ID: <20120228.140558.1132853996225815681.davem@davemloft.net>
References: <4F4B8C66.5060206@collabora.co.uk>
	<20120227.140535.1623396420455657443.davem@davemloft.net>
	<1330426059.2139.21.camel@megeve>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: javier.martinez@collabora.co.uk, javier@collabora.co.uk,
	eric.dumazet@gmail.com, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rodrigo.moya@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330426059.2139.21.camel@megeve>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rodrigo Moya <rodrigo.moya@collabora.co.uk>
Date: Tue, 28 Feb 2012 11:47:39 +0100

> Because of all of this, UDP/IP multicast wasn't even considered as an
> option. We might be wrong in some/all of those, so could you please
> comment on them to check if that's so?

You guys seem to want something that isn't AF_UNIX, ordering guarentees
and whatnot, it really has no place in these protocols.

You've designed a userlevel subsystem with requirements that no existing
socket layer can give, and you just figured you'd work that out later.

I think you rather should have reconsidered these premises and designed
something that could handle reality which is AF_UNIX can't do multicast
and nobody guarentees those strange ordering requirements you seem to
have.
