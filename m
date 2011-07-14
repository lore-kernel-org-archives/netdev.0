From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] ps3_gelic: Fix error paths when a tx dma fails
Date: Thu, 14 Jul 2011 08:35:48 -0700 (PDT)
Message-ID: <20110714.083548.1565604077412861146.davem@davemloft.net>
References: <1310501606-829-1-git-send-email-a.heider@gmail.com>
	<4E1E1CDE.2060504@infradead.org>
	<CAHsu+b89+SN8RE4Ce-evC97pw8bgZgjnOW_+z6NDXu6bGuRO+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: geoff@infradead.org, netdev@vger.kernel.org,
	cbe-oss-dev@lists.ozlabs.org
To: a.heider@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108Ab1GNPjL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 11:39:11 -0400
In-Reply-To: <CAHsu+b89+SN8RE4Ce-evC97pw8bgZgjnOW_+z6NDXu6bGuRO+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andre Heider <a.heider@gmail.com>
Date: Thu, 14 Jul 2011 10:36:32 +0200

> Hey Geoff,
>=20
> On Thu, Jul 14, 2011 at 12:31 AM, Geoff Levand <geoff@infradead.org> =
wrote:
>> Hi Andre,
>>
>> On 07/12/2011 01:13 PM, Andre Heider wrote:
>>> This series fixes a few bugs for the error paths once a tx dma requ=
est
>>> fails. Without these I either ran into BUG_ON, the device got kille=
d,
>>> or the kernel crashed.
>>
>> Thanks for preparing the fixes. =A0I added them to my ps3-linux
>> tree and did some quick tests which didn't show any problems.
>> I'll try to do some more through testing with them sometime
>> soon.
>=20
> nice, thanks :)

Should I toss these into net-next-2.6 now?
