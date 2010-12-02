From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH v2 1/4] net: snmp: fix the wrong ICMP_MIB_MAX value
Date: Thu, 02 Dec 2010 18:35:50 +0800
Message-ID: <4CF77686.5010305@cn.fujitsu.com>
References: <4CF71ADB.5060702@cn.fujitsu.com> <20101202095753.GA10221@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network-Maillist <netdev@vger.kernel.org>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61267 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751043Ab0LBKhb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 05:37:31 -0500
In-Reply-To: <20101202095753.GA10221@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote, at 12/02/2010 05:57 PM:
>>  /* ICMP */
>>  #define ICMP_MIB_DUMMY	__ICMP_MIB_MAX
>> -#define ICMP_MIB_MAX	(__ICMP_MIB_MAX + 1)
>> -
>> +#define ICMP_MIB_MAX	__ICMP_MIB_MAX
>=20
> Looks like the +1 is there to account for ICMP_MIB_DUMMY. It is
> unused though but you have to remove it as well if you want to
> kill that extra +1.

I don't know the history about ICMP_MIB_DUMMY before v2.6.12-rc2.=20
But after that, it is abandoned.

ICMP_MIB_DUMMY is killed in patch:
=EF=BC=BBPATCH v2 4/4] net: kill unused macros from head file

--=20
Best Regards
-----
Shan Wei
