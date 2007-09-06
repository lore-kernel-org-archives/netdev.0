From: FNST-Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [Spam-fortigate] Re: [PATCH 1/1] netcore: minor cleanup for register_netdevice
Date: Thu, 06 Sep 2007 13:37:55 +0800
Message-ID: <46DF9233.5030809@cn.fujitsu.com>
References: <46DF8FBC.20106@cn.fujitsu.com> <20070906.143402.07329837.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ellre923@gmail.com, krkumar2@in.ibm.com
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:63204 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751886AbXIFFiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 01:38:25 -0400
In-Reply-To: <20070906.143402.07329837.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

oops
i am wrong

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E said the follo=
wing on 2007-9-6 13:34:
> I disagree.  Some of "dev->init()" functions set up dev->iflink;
> e.g., ipip_tunnel_init() etc.
>
> In article <46DF8FBC.20106@cn.fujitsu.com> (at Thu, 06 Sep 2007 13:27=
:24 +0800), FNST-Wang Chen <wangchen@cn.fujitsu.com> says:
>
>  =20
>> - minor logic cleanup
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>>
>> diff -Nurp linux-2.6.22.4.org/net/core/dev.c  linux-2.6.22.4/net/cor=
e/dev.c
>> --- linux-2.6.22.4.org/net/core/dev.c    2007-08-22 15:33:40.0000000=
00=20
>> +0800
>> +++ linux-2.6.22.4/net/core/dev.c    2007-09-06 13:27:35.000000000 +=
0800
>> @@ -3075,8 +3075,6 @@ int register_netdevice(struct net_device
>>     dev->xmit_lock_owner =3D -1;
>>     spin_lock_init(&dev->ingress_lock);
>>
>> -    dev->iflink =3D -1;
>> -
>>     /* Init, if this function is available */
>>     if (dev->init) {
>>         ret =3D dev->init(dev);
>> @@ -3093,8 +3091,7 @@ int register_netdevice(struct net_device
>>     }
>>
>>     dev->ifindex =3D dev_new_index();
>> -    if (dev->iflink =3D=3D -1)
>> -        dev->iflink =3D dev->ifindex;
>> +    dev->iflink =3D dev->ifindex;
>>
>>     /* Check for existence of name */
>>     head =3D dev_name_hash(dev->name);
>>
>>
>>
>>
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>    =20
>
>
>
>  =20


--=20
Best Regards,
A new email address of FJWAN is launched from Apr.1 2007.
The updated address is: wangchen@cn.fujitsu.com
--------------------------------------------------
Wang Chen
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL=EF=BC=9A+86+25-86630566-850
=46UJITSU INTERNAL=EF=BC=9A79955-850
=46AX=EF=BC=9A+86+25-83317685
MAIL=EF=BC=9Awangchen@cn.fujitsu.com
--------------------------------------------------



