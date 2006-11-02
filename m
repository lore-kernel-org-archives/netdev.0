From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: Re: IPv6 and rt6_lookup()
Date: Thu, 02 Nov 2006 18:19:06 +0100
Message-ID: <454A288A.7050107@6wind.com>
References: <454A1BF7.6030500@6wind.com> <454A24B7.1010109@hp.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.net-streams.fr ([62.23.133.110]:30727 "EHLO
	net-streams.fr") by vger.kernel.org with ESMTP id S1750831AbWKBRQp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 12:16:45 -0500
To: Vlad Yasevich <vladislav.yasevich@hp.com>
In-Reply-To: <454A24B7.1010109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 02.11.2006 18:02, Vlad Yasevich a =E9crit :
> Nicolas DICHTEL wrote:
>> Hello,
>>
>> Suppose that a host has autoconfiguration enabled. It will take RA t=
o
>> autoconfigure an IPv6 address. For example,
>> 2001:0db8:3008:c1ca:2d0:b7ff:febb:4aee/64.
>> This host will create a route entry for this onlink prefix (dst:
>> 2001:0db8:3008:c1ca::/64)
>> in the MAIN table with the lifetime present in prefix option in RA.
>> Each time this host will receive a RA, it will update this lifetime.=
 To
>> do this,
>> it will call rt6_lookup() (in addrconf_prefix_rcv()) to find the ent=
ry.
>>
>> Now, suppose that our host joins this anycast group:
>> "2001:0db8:3008:c1ca::0". A route
>
> Hmm... you are configuring a subnet router anycast address on host an=
d=20
> the implementation lets you do it?  That's not good.  I don't think
> you sould be permitted to configure a subnet router anycast address
> on a host that autoconfigures it's interface.
The current implementation allow this and I don't know if we must=20
prohibit this.
=46or example, in case of NEMO (RFC3963), router may autoconfigured its=
=20
address.

Nicolas
