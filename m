From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
 non-drops and modifying end-of-line points for skbs
Date: Wed, 11 Mar 2009 17:34:47 +0100
Message-ID: <49B7E827.3070203@cosmosbay.com>
References: <20090303170307.GD1480@hmsreliant.think-freely.org>	<20090305210105.GC12835@hmsreliant.think-freely.org> <20090311.091830.152269823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56176 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbZCKQkQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 12:40:16 -0400
In-Reply-To: <20090311.091830.152269823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu, 5 Mar 2009 16:01:05 -0500
>=20
>> Ok, as requested, new version of this patch to add in bifurcation of=
 kfree_skb
>> into two versions, one for legitimate kfree's, and one for drops
>>
>> Modification Notes:
>> 1) Renamed kfree_skb_clean to consume_skb, to better identify points=
 where we
>> are finished with an skb
>>
>> 2) checkpatch cleanups
>=20
> Looks good.
>=20
> Respin everything with the requested changes I asked for in #4
> and I can likely toss this into net-next-2.6, thanks!

I was wondering if packets droped at NIC level are handled by "Network =
Drop Monitor".
(See recent discussion about Multicast packet loss)

I believe not, maybe I missed something ...

