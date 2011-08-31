From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 10:31:48 +0200
Message-ID: <20110831083147.GC2010@minipsycho.brq.redhat.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
 <1314715608-978-2-git-send-email-jpirko@redhat.com>
 <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
 <20110830112553.012ffa85@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34243 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980Ab1HaIbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 04:31:51 -0400
Content-Disposition: inline
In-Reply-To: <20110830112553.012ffa85@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 30, 2011 at 08:25:53PM CEST, shemminger@vyatta.com wrote:
>On Tue, 30 Aug 2011 20:11:37 +0200
>Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:
>
>> 2011/8/30 Jiri Pirko <jpirko@redhat.com>:
>> > Allow to write to "carrier" attribute. Devices may implement ndo_c=
hange_carrier
>> > callback to allow changing carrier from userspace.
>>=20
>> Do you expect drivers using implementation different than just calli=
ng
>> netif_carrier_on/off? Or is it supposed to also e.g. power down PHYs=
?
>>=20
>> BTW, I like this feature!
>
>Ok for virtual devices, but please don't implement it in real hardware=
=2E
>There is already enough breakage in carrier management in applications=
=2E
>It also overlaps with operstate perhaps that is a more more complete
>solution.

Looking at operstate doc, I'm not sure what exactly do you mean by
"overlapping".

The main purpose of my patch is to give certain virt devices the
opportunity to emulate carrier loss. But I do not see reason why this
can't be implemented by real hw. Or course there should be explicitelly
documented the purpose of this feature.

Jirka
>
