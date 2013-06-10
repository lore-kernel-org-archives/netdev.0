From: =?ISO-8859-1?Q?Holger_Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: [PATCH v2 net 1/1] r8169: fix offloaded tx checksum for small
 packets.
Date: Mon, 10 Jun 2013 13:12:10 +0200
Message-ID: <51B5B48A.5040807@googlemail.com>
References: <20130518112446.GA21268@electric-eye.fr.zoreil.com> <5197936C.6090607@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:19402 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab3FJLMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 07:12:16 -0400
In-Reply-To: <5197936C.6090607@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.05.2013 16:42, Holger Hoffst=E4tte wrote:
> On 18.05.2013 13:24, Francois Romieu wrote:
>> 8168evl offloaded checksums are wrong since commit
>> e5195c1f31f399289347e043d6abf3ffa80f0005 ("r8169: fix 8168evl frame =
padding.")
>> pads small packets to 60 bytes (without ethernet checksum). Typical =
symptoms
>> appear as UDP checksums which are wrong by the count of added bytes.
>>
>> It isn't worth compensating. Let the driver checksum.
>>
>> Due to the skb length changes, TSO code is moved before the Tx descr=
iptor gets
>> written.
>>
>> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>=20
> Tested again, still working for me.
>=20
> Tested-by: Holger Hoffst=E4tte <holger.hoffstaette@googlemail.com>

ping:

As far as I can tell this patch is still not in -stable 3.9.5 or queued
up for the next iteration.

Commit in Linus' tree is b423e9ae49d78ea3f53b131c8d5a6087aed16fd6

thanks :)

-h
