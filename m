From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Tue, 29 Nov 2011 10:19:21 +0100
Message-ID: <4ED4A399.6090709@sophos.com>
References: <CAF9AA63.1622%ulrich.weber@sophos.com> <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Amos Jeffries <squid3@treenet.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6.sophos.com ([213.31.172.36]:51233 "EHLO mx6.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753997Ab1K2JTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 04:19:23 -0500
In-Reply-To: <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please dont' let this deviate to a flame war.
I just said there are use cases, nothing more, nothing less.

This is software. There are lots of ways to archive the same goal.
Every solution has its pro and cons, its not always black and white.


On 28.11.2011 23:03, Amos Jeffries wrote:
> I'm going to dare to call FUD on those statements...
>    * Load Balancing - what is preventing your routing rules or packet
>   marking using the same criteria as the NAT changer? nothing. Load
>   balancing works perfectly fine without NAT.
>
Nothing, you archive the same in a different way.
However keep in mind that not all computers out there run Linux.

Its quite simple to setup NAT rules, they work with every OS.

On the other hand, balancing by changing MAC address or
IPv6inIPv6 Tunnels can be a headache, getting this going with
Windows, Mac, Solaris and so on.

Issues with DAD and source address selection doesn't make it easier.
Have a look at net/netfilter/ipvs/ip_vs_xmit.c. There is a reason, why
NAT for IPv6 is already in the Kernel since three years.

>    * outgoing packet control - packets will happily leave the "wrong"
>   interface after NAT unless you add routing and firewall controls
>   separate to NAT. Packet control works *better* without NAT erasing
>   original IP information resulting in mistakenly NAT'ed packets go o=
ut
>   the wrong interface.
>
>
I fully agree. NAT can not replace your firewall rules.

However with NAT you could get some kind of anonymity.
Think of Tor: If your server/client operates with private IP addresses,
your public IP address is still masked after a security breach.

>   I have long been of the opinion that all NAT really offers is the
>   ability to easily and cleanly multi-home several global public pref=
ixes
>   from a unified PI space. This is a very important aspect for some
>   networks, even with plentiful IPv6 addresses.
Also in my opinion the most important reason for NAT.

Cheers
  Ulrich

--=20
Ulrich Weber | ulrich.weber@sophos.com | Senior Software Engineer
Astaro - a Sophos company | Amalienbadstr 41 | 76227 Karlsruhe | German=
y
Phone +49-721-25516-0 | Fax =E2=80=93200 | www.astaro.com
