From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 22:26:45 +0200
Message-ID: <20110831202644.GD2051@minipsycho.redhat.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
 <1314715608-978-2-git-send-email-jpirko@redhat.com>
 <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
 <20110831082655.GB2010@minipsycho.brq.redhat.com>
 <CAHXqBFJpSZNhkur7QNYbjG-=Bkq2HtHKEHsn+H3TnEJ5NezJoA@mail.gmail.com>
 <20110831084511.GD2010@minipsycho.brq.redhat.com>
 <4E5E939C.5000009@gmail.com>
 <1314821537.3274.24.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753525Ab1HaU0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 16:26:50 -0400
Content-Disposition: inline
In-Reply-To: <1314821537.3274.24.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 31, 2011 at 10:12:17PM CEST, bhutchings@solarflare.com wrote:
>On Wed, 2011-08-31 at 22:03 +0200, Nicolas de Peslo=FCan wrote:
>> Le 31/08/2011 10:45, Jiri Pirko a =E9crit :
>>=20
>> >>>> Do you expect drivers using implementation different than just =
calling
>> >>>> netif_carrier_on/off? Or is it supposed to also e.g. power down=
 PHYs?
>> >>> Yes, generally it can be used also for en/disable phy, for testi=
ng
>> >>> purposes if hw and driver would support it.
>> >>
>> >> I'd like to see this working for GRE tunnel devices (for keepaliv=
e
>> >> daemon to be able to indicate to routing daemons whether tunnel i=
s
>> >> really working) - implementation would be identical to dummy's ca=
se.
>> >> Should I prepare a patch or can I leave it to you?
>> >
>> > Ok, I can include it to this patchset (I'm going to repost first p=
atch
>> > anyway)
>>=20
>> Can't we assume that the dummy's case is the default behavior and
>> register this default=20
>> ndo_change_carrier callback for every device ?
>
>You have got to be joking.  No device driver that has real link
>monitoring should use this implementation.
>
>[...]
>> If someone is not confident with this default callback registered fo=
r
>> all device, at least, we can=20
>> put this code in a common place, so that a driver willing to use it
>> doesn't need to have its own=20
>> version of it.
>
>I agree that this might be useful in some other software devices,
>though.

Maybe it would be better to just add priv_flag for this instead of
introducing netdev_op. Then do on/off is this flag is set. Not sure
though...

Jirka

>
>Ben.
>
>--=20
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
