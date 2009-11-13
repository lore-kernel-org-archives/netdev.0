From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 08:40:05 -0800
Message-ID: <4AFD8BE5.3020909@candelatech.com>
References: <200911130701.14847.opurdila@ixiacom.com> <200911130720.19671.opurdila@ixiacom.com> <4AFCF8D3.6090905@gmail.com> <200911131155.43714.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44468 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262AbZKMQkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 11:40:02 -0500
In-Reply-To: <200911131155.43714.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> On Friday 13 November 2009 08:12:35 you wrote:
>  =20
>> Octavian Purdila a =E9crit :
>>    =20
>>> On Friday 13 November 2009 07:01:14 you wrote:
>>>      =20
>>>> This patch speeds up the network device name allocation for the ca=
se
>>>> where a significant number of devices of the same type are created
>>>> consecutively.
>>>>
>>>> Tests performed on a PPC750 @ 800Mhz machine with per device sysct=
l
>>>> and sysfs entries disabled:
>>>>
>>>> Without the patch           With the patch
>>>>
>>>> real    0m 43.43s	    real    0m 0.49s
>>>> user    0m 0.00s	    user    0m 0.00s
>>>> sys     0m 43.43s	    sys     0m 0.48s
>>>>        =20
>>> Oops, pasting root prompts (e.g. # modprobe ....) directly into the=
 git
>>> commit message is not a good idea :) Here it is again, with the ful=
l
>>> commit message.
>>>
>>> [net-next-2.6 PATCH] net: fast consecutive name allocation
>>>
>>> This patch speeds up the network device name allocation for the cas=
e
>>> where a significant number of devices of the same type are created
>>> consecutively.
>>>
>>> Tests performed on a PPC750 @ 800Mhz machine with per device sysctl
>>> and sysfs entries disabled:
>>>
>>> $ time insmod /lib/modules/dummy.ko numdummies=3D8000
>>>
>>> Without the patch           With the patch
>>>
>>> real    0m 43.43s	    real    0m 0.49s
>>> user    0m 0.00s	    user    0m 0.00s
>>> sys     0m 43.43s	    sys     0m 0.48s
>>>
>>> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
>>> ---
>>>      =20
>> Honestly I dont like this bloat.
>>
>> Changing dummy.c is trivial, and you can allocate 100.000.000 dummie=
s if
>>  you want now :)
>>
>>    =20
>
> Yep we can do that - actually we are doing exactly this in our driver=
s. But in=20
> that way, you get to "bloat" every driver which needs this.=20
>  =20
=46or mac-vlans, .1q vlans, VETH, at least, you can choose the name whe=
n=20
you create them
via 'ip'.  So, you can do the logic in user-space.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>=20
Candela Technologies Inc  http://www.candelatech.com


