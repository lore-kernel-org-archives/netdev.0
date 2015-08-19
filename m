From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] lwtunnel: Fix the sparse warnings in fib_encap_match
Date: Wed, 19 Aug 2015 15:41:53 +0800
Message-ID: <55D43341.1010507@windriver.com>
References: <1439969609-11189-1-git-send-email-ying.xue@windriver.com> <20150819094003.65ff7185@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<fengguang.wu@intel.com>, <kbuild-all@01.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:37000 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803AbbHSHmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 03:42:07 -0400
In-Reply-To: <20150819094003.65ff7185@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2015 03:40 PM, Jiri Benc wrote:
> On Wed, 19 Aug 2015 15:33:29 +0800, Ying Xue wrote:
>> When CONFIG_LWTUNNEL config is not enabled, the lwtstate_free() is n=
ot
>> declared in lwtunnel.h at all. However, even in this case, the funct=
ion
>> is still referenced in fib_semantics.c so that there appears the
>> following sparse warnings:
>>
>> net/ipv4/fib_semantics.c:553:17: error: undefined identifier 'lwtsta=
te_free'
>>   CC      net/ipv4/fib_semantics.o
>>   net/ipv4/fib_semantics.c: In function =E2=80=98fib_encap_match=E2=80=
=99:
>>   net/ipv4/fib_semantics.c:553:3: error: implicit declaration of fun=
ction =E2=80=98lwtstate_free=E2=80=99 [-Werror=3Dimplicit-function-decl=
aration]
>>   cc1: some warnings being treated as errors
>>   make[1]: *** [net/ipv4/fib_semantics.o] Error 1
>>   make: *** [net/ipv4/fib_semantics.o] Error 2
>>
>> To eliminate the error, we define an empty function for lwtstate_fre=
e()
>> in lwtunnel.h when CONFIG_LWTUNNEL is disabled.
>>
>> Fixes: df383e6240ef ("lwtunnel: fix memory leak")
>> Cc: Jiri Benc <jbenc@redhat.com>
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>=20
> Acked-by: Jiri Benc <jbenc@redhat.com>
>=20
> Thanks, you beat me to it.
>=20
> This is for net-next.
>=20

Yes, I found I made a mistake after I sent out the patch.

I will resend the patch to net-next tree again.

Thanks,
Ying

>  Jiri
>=20
