From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Wed, 22 Oct 2008 16:58:17 -0700
Message-ID: <48FFBE19.7010803@hp.com>
References: <20081020190922.7dd6510a@extreme>	<20081020.221857.209830018.davem@davemloft.net>	<48FE34AF.8050508@hp.com> <48FE386F.8090706@cosmosbay.com> <20081021133811.68bd5ce1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:3685 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbYJVX6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 19:58:21 -0400
In-Reply-To: <20081021133811.68bd5ce1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 21 Oct 2008 22:15:43 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>=20
>>Rick Jones a =E9crit :
>>> I've not had a good emily litella moment all day so I'll ask - is
>>> there really that much in the way of suitable skb's which are
>>> completely free after transmit completion?
>>
>> Or, if we take another way, say a VOIP RTP machine sends and
>> receive 20.000 packets per second, each being 200 bytes long, are
>> transmited packets correctly sized at sendto() time to be
>> candidates for recycling ?
>=20
> No. Most locally generate packets aren't going to be right size
> because they will be too small, cloned or fragmented.  It really only
> helps when forwarding.

So we have a bit of "tension" between the desires of an end host vs=20
those of a router right?

rick jones
