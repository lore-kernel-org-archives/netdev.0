From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Tue, 30 Aug 2011 11:25:53 -0700
Message-ID: <20110830112553.012ffa85@nehalam.ftrdhcpuser.net>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
 <1314715608-978-2-git-send-email-jpirko@redhat.com>
 <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39312 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755971Ab1H3SZn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 14:25:43 -0400
In-Reply-To: <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Aug 2011 20:11:37 +0200
Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:

> 2011/8/30 Jiri Pirko <jpirko@redhat.com>:
> > Allow to write to "carrier" attribute. Devices may implement ndo_ch=
ange_carrier
> > callback to allow changing carrier from userspace.
>=20
> Do you expect drivers using implementation different than just callin=
g
> netif_carrier_on/off? Or is it supposed to also e.g. power down PHYs?
>=20
> BTW, I like this feature!

Ok for virtual devices, but please don't implement it in real hardware.
There is already enough breakage in carrier management in applications.
It also overlaps with operstate perhaps that is a more more complete
solution.
