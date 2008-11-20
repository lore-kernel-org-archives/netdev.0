From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Thu, 20 Nov 2008 06:21:29 +0100
Message-ID: <4924F3D9.3020908@cosmosbay.com>
References: <20081117234207.854110282@vyatta.com>	<20081119.173353.251644773.davem@davemloft.net> <20081119190212.6d589358@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60190 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbYKTFVe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 00:21:34 -0500
In-Reply-To: <20081119190212.6d589358@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Wed, 19 Nov 2008 17:33:53 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
>=20
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Mon, 17 Nov 2008 15:42:07 -0800
>>
>>> This sequence of patches breaks the network device adminstration=20
>>> function table away from the network device data structure. It is
>>> a transitional API change (both keep working), and this set of patc=
hes
>>> hits a range of commonly used drivers. This should be enough to mak=
e sure
>>> both old and new interfaces get used and tested.
>> I'm starting to apply these patches, thanks Stephen.
>>
>> I really think we should move even fast-path function pointers
>> here.  When we have tons of virtual devices configured, it
>> doesn't make sense for us to touch tons of ->hard_start_xmit
>> pointer values which all evaluate to the same thing.
>>
>> ops are ops
>=20
> I have some more pending. I'll add neigh_setup and xmit stuff.

So if you plan to release a new release of Network Device Ops...

I would have one suggestion about these ops, that would be to prefix
method names (open, close, ...) by a ndo_ or something that ease grepin=
g...

Thanks

