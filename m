From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Thu, 2 Jan 2014 22:49:02 -0800 (PST)
Message-ID: <1388731742.39393.YahooMailBasic@web125506.mail.ne1.yahoo.com>
References: <20140103063041.GJ22494@order.stressinduktion.org>
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
Received: from nm44.bullet.mail.ne1.yahoo.com ([98.138.120.51]:37788 "HELO
	nm44.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750860AbaACGtX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 01:49:23 -0500
In-Reply-To: <20140103063041.GJ22494@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1/3/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:

On Thu, Jan 02, 2014 at 10:19:24PM  -0800, Fran=E7ois-Xavier Le Bail wr=
ote:

>> Some setup may use a ping to Subnet-Router anycast
>> address and expect a reply to discover a unicast address
>> (not very secure, but ...).
>>
>> It is the reason why, I want to keep existing default.
=20
> Yep, with pre-defined anycast address I actually meant the
> subnet router
> anycast address. We currently don't need to deal with more
> than that one:
> https://www.iana.org/assignments/ipv6-anycast-addresses/ipv6-anycast-=
addresses.xhtml
=20
> As soon as this patch gets applied, we have to keep the knob stable
> in its semantic.=A0 So my proposal would be to change the knob to jus=
t
> control the behaviour of ping replies and also change its
> name to reflect this.
=20
> Leave datagram sending with specific anycast address as
> source just open and
> don't protect it with this knob. Would that be a plan?
=20
But service discovery may be done also with UDP, so I see the knob as a=
 router policy:
It enable or not anycast source.
