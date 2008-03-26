From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 1/2 net-2.6.26] [NETNS]: Compilation fix for include/linux/netdevice.h.
Date: Wed, 26 Mar 2008 09:51:12 +0100
Message-ID: <47EA0E80.2070302@fr.ibm.com>
References: <1206517259-29152-1-git-send-email-den@openvz.org> <20080326.004742.92048899.davem@davemloft.net> <20080326.170702.24448643.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, den@openvz.org, netdev@vger.kernel.org,
	devel@openvz.org, containers@lists.osdl.org, xemul@openvz.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:16354 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbYCZIwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 04:52:06 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m2Q8q5qn142256
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 08:52:05 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2Q8q4oD1904734
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 08:52:04 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2Q8q4p7004278
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 08:52:04 GMT
In-Reply-To: <20080326.170702.24448643.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080326.004742.92048899.davem@davemloft.net> (at Wed, 26=
 Mar 2008 00:47:42 -0700 (PDT)), David Miller <davem@davemloft.net> say=
s:
>=20
>> From: "Denis V. Lunev" <den@openvz.org>
>> Date: Wed, 26 Mar 2008 10:40:58 +0300
>>
>>> Commit commit c346dca10840a874240c78efe3f39acf4312a1f2
>>> ([NET] NETNS: Omit net_device->nd_net without CONFIG_NET_NS)
>>> breaks compilation with CONFIG_NET_NS set.
>>>
>>> Fix the typo.
>>>
>>> Signed-off-by: Denis V. Lunev <den@openvz.org>
>> Applied.
>>
>> Too bad allmodconfig doesn't enable things which are y/n only.
>=20
> Sorry for the typo.
>=20
> Unfortunately, NET_NS depends on !SYSFS,
> so allyesconfig might not help...

Eric Biederman told us he has community acceptance for his approach and=
=20
he will push sysfs per namespace in a few weeks.
