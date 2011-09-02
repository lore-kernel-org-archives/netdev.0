From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [RFC, 1/2] ethtool: Implement private flags interface for
 ethtool application.
Date: Fri, 2 Sep 2011 14:29:22 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F0173FF8648@orsmsx508.amr.corp.intel.com>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
 <20110902.165524.1076389492712310664.davem@davemloft.net>
 <EDC0E76513226749BFBC9C3FB031318F0173FF8607@orsmsx508.amr.corp.intel.com>
 <CAHXqBFKU2m6s1fQzZpJRvvR2HatJpXjWXv84=ZYD5E6OPFfUmQ@mail.gmail.com>
 <CAHXqBF+9iP6tOmtiaXopGvLyBZvpXmLz05aHj1MrQ2RnAiGGLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45513 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756044Ab1IBV3Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 17:29:24 -0400
In-Reply-To: <CAHXqBF+9iP6tOmtiaXopGvLyBZvpXmLz05aHj1MrQ2RnAiGGLA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Micha=B3 Miros=B3aw [mailto:mirqus@gmail.com]
>Sent: Friday, September 02, 2011 2:22 PM
>To: Wyborny, Carolyn
>Cc: David Miller; bhutchings@solarflare.com; netdev@vger.kernel.org
>Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface for
>ethtool application.
>
>W dniu 2 wrze=B6nia 2011 23:17 u=BFytkownik Micha=B3 Miros=B3aw
><mirqus@gmail.com> napisa=B3:
>> 2011/9/2 Wyborny, Carolyn <carolyn.wyborny@intel.com>:
>>>>-----Original Message-----
>>>>From: David Miller [mailto:davem@davemloft.net]
>>>>Sent: Friday, September 02, 2011 1:55 PM
>>>>To: Wyborny, Carolyn
>>>>Cc: bhutchings@solarflare.com; netdev@vger.kernel.org
>>>>Subject: Re: [RFC, 1/2] ethtool: Implement private flags interface
>for
>>>>ethtool application.
>>>>
>>>>From: Carolyn Wyborny <carolyn.wyborny@intel.com>
>>>>Date: Fri, =A02 Sep 2011 13:50:30 -0700
>>>>
>>>>> This patch completes the user space implementation of the private
>>>>> flags inteface in ethtool. Using -b/-B options.
>>>>>
>>>>> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
>>>>
>>>>The only use case you show here is something generic which other
>>>>chips have, Energy Efficient Ethernet.
>>>>
>>>>Making an attribute private which is present widely amonst various
>>>>networking chips makes no sense at all.
>>>>
>>>>It deserved a generic ethtool flag.
>>>
>>> Fair enough on this particular feature, but does that negate the
>implementation suggestion altogether? =A0I can send an updated feature
>implementation for the use case using DMA Coalescing if that will help=
=2E
>> I would rather see this as an extension to ETHTOOL_[GS]FEATURES. Its
>> semantics allow easy expanding to handle device-private flags withou=
t
>> changing anything on userspace side.
>
>BTW, After pending Intel drivers get converted to ndo_set_features and
>netdev->features get extended to 64 bits, it would also be possible to
>use some of the unused bits there for device/driver-private flags
>almost "for free".
>
>Best Regards,
>Micha=B3 Miros=B3aw

That seems reasonable as then there would be room for them, but is it g=
oing to be OK to use those unused bits or are they going to be intended=
 for generic features and not device specific ones? =20

Is the intent then to not ever use the priv_flags partial implementatio=
n? =20

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
