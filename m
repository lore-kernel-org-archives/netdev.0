From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Thu, 2 Jan 2014 22:19:24 -0800 (PST)
Message-ID: <1388729964.50446.YahooMailBasic@web125501.mail.ne1.yahoo.com>
References: <1388728736.50849.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm46.bullet.mail.ne1.yahoo.com ([98.138.120.53]:38413 "HELO
	nm46.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750827AbaACGWJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 01:22:09 -0500
In-Reply-To: <1388728736.50849.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1/3/14, Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com> wrote:

--------------------------------------------
 On Thu, 1/2/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrot=
e:
 =20
>> Ah, I guess you are hinting at the situation where you
>> ping
>> a pre-defined
>> anycast address and expect back a unicast address for
>> discovering the unicast
>> address of a router e.g.? Ok, I see...
 =20
> Exact

more:=20
Some setup may use a ping to Subnet-Router anycast address and expect a=
 reply to discover a unicast address (not very secure, but ...).

It is the reason why, I want to keep existing default.
