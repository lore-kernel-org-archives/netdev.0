From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 04:38:38 -0800 (PST)
Message-ID: <1389098318.83283.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm32.bullet.mail.ne1.yahoo.com ([98.138.229.25]:45159 "HELO
	nm32.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751584AbaAGMre convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 07:47:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1/6/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:

>>But if an echo request arrive on an interface
>> which do not listen at this LL anycast, is a reply can occur ?
=20
> I thought quite the opposite with anycast + forwarding
> enabled, that=A0 we would process the packet.

yes, for a global scope anycast.
But a routers must not forward any packets with link-local source or de=
stination addresses to other links, thus also ll anycast.

BR
=46ran=E7ois-Xavier
