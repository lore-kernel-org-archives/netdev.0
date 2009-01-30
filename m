From: Benjamin ZORES <benjamin.zores@alcatel-lucent.fr>
Subject: Re: [PATCH] Fix infinite retry loop in IP-Config
Date: Fri, 30 Jan 2009 09:25:39 +0100
Message-ID: <4982B983.6020704@alcatel-lucent.fr>
References: <20090128105220.GB4190@ff.dom.local>	<49804AAF.7020702@alcatel-lucent.fr> <20090129.161929.241520668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smail4.alcatel.fr ([62.23.212.167]:60428 "EHLO
	smail4.alcatel.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbZA3I1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 03:27:30 -0500
Received: from bsf.alcatel.fr (mail205.sxb.bsf.alcatel.fr [155.132.205.115])
	by smail4.alcatel.fr (ALCANET/NETFR) with ESMTP id n0U8RRi5012916
	for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 09:27:28 +0100
Received: from mail (mail-bsf-alcatel-fr.sxb.bsf.alcatel.fr [155.132.205.91])
	by bsf.alcatel.fr (8.8.8p2+Sun/8.9.3) with ESMTP id JAA28978
	for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 09:27:27 +0100 (MET)
Received: from [172.25.51.190] (frilld0f09516 [172.25.51.190])
	by mail (8.8.8p2+Sun/) with ESMTP id JAA28972
	for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 09:27:26 +0100 (MET)
In-Reply-To: <20090129.161929.241520668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Benjamin ZORES <benjamin.zores@alcatel-lucent.fr>
> Date: Wed, 28 Jan 2009 13:08:15 +0100
>
>  =20
>> Jarek Poplawski a =E9crit :
>>    =20
>>> On 28-01-2009 10:07, Benjamin ZORES wrote:
>>>  =20
>>>      =20
>>>> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
>>>> index 42a0f3d..4911b81 100644
>>>> --- a/net/ipv4/ipconfig.c
>>>> +++ b/net/ipv4/ipconfig.c
>>>> @@ -1268,6 +1268,7 @@ __be32 __init root_nfs_parse_addr(char *name=
)
>>>>  static int __init ip_auto_config(void)
>>>>  {
>>>>  	__be32 addr;
>>>> +	 int retries =3D CONF_OPEN_RETRIES;
>>>>    =20
>>>>        =20
>>>  Doesn't it need "#ifdef IPCONFIG_DYNAMIC" to prevent a compiler
>>> warning? I guess you could add a "Signed-off-by:" line BTW.
>>>  =20
>>>      =20
>> You're perfectly right about this.
>> Attached an updated version of the patch.
>>    =20
>
> Patch applied, thank you.
Be my guest. Thanks to you.

Ben
