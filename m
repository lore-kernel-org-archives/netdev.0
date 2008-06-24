From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 5/8] ipv6: Check return of dev_set_allmulti
Date: Tue, 24 Jun 2008 13:01:43 +0800
Message-ID: <48607FB7.9050908@cn.fujitsu.com>
References: <485AFFFB.5040901@cn.fujitsu.com> <20080624.125243.112730755.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58573 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbYFXFGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 01:06:18 -0400
In-Reply-To: <20080624.125243.112730755.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E said the follo=
wing on 2008-6-24 11:52:
> In article <485AFFFB.5040901@cn.fujitsu.com> (at Fri, 20 Jun 2008 08:=
55:23 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:
>=20
>> allmulti might overflow.
>> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-ne=
xt makes
>> dev_set_promiscuity/allmulti return error number if overflow happene=
d.
>>
>> Here, we check the positive increment for allmulti to get error retu=
rn.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>=20
> The comment is too obvious to have.
>=20

It's just explain the background of this series of fix.

