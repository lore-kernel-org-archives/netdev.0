From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridging + load balancing bonding
Date: Fri, 23 Oct 2009 11:54:21 +0200
Message-ID: <4AE17D4D.7040808@gmail.com>
References: <20091022122339.GA20148@spaans.fox.local> <4AE07D3C.3040702@gmail.com> <20091023083851.GA18457@spaans.fox.local> <4AE16F83.7080400@gmail.com> <20091023095137.GA22424@spaans.fox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40108 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbZJWJ4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 05:56:38 -0400
In-Reply-To: <20091023095137.GA22424@spaans.fox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jasper Spaans a =E9crit :
> On Fri, Oct 23, 2009 at 10:55:31AM +0200, Eric Dumazet wrote:
>=20
>> Dont you think special attention is needed for multicast/broadcast t=
rafic
>> (they should be sent to both IDS) ?
>=20
> Not really -- AFAIK we're currently not using the information encapsu=
lated
> in broadcast traffic to judge the unicast packets. Besides, we're
> aggregating the results from the IDSes, so it shouldn't matter on whi=
ch node
> a packet is processed.
>=20
> But if the need arises, this could be added quite easily to the code.
>=20

OK

I found following very interesting article that can give pretty good ad=
vices

http://lwn.net/Articles/145406/

