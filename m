From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Problem wit route cache
Date: Mon, 08 Feb 2010 14:33:48 +0100
Message-ID: <4B7012BC.9000702@itcare.pl>
References: <4B700EC2.5090207@itcare.pl> <1265635690.3048.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010305020902080908090908"
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r242-20.iq.pl ([86.111.242.20]:43665 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751744Ab0BHNds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 08:33:48 -0500
In-Reply-To: <1265635690.3048.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010305020902080908090908
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

W dniu 2010-02-08 14:28, Eric Dumazet pisze:
> Le lundi 08 février 2010 à 14:16 +0100, Paweł Staszewski a écrit :
>    
>> Hello
>>
>>   From some time i have problem with route cache in linux
>> this is an info that i have in dmesg:
>>
>> Route hash chain too long!
>> Adjust your secret_interval!
>> Route hash chain too long!
>> Adjust your secret_interval!
>> Route hash chain too long!
>> Adjust your secret_interval!
>> Route hash chain too long!
>> Adjust your secret_interval!
>> Route hash chain too long!
>> Adjust your secret_interval!
>> Route hash chain too long!
>> Adjust your secret_interval!
>> Route hash chain too long!
>> Adjust your secret_interval!
>> Route hash chain too long!
>> Adjust your secret_interval!
>> vlan0811: 9 rebuilds is over limit, route caching disabled
>> Route hash chain too long!
>> Adjust your secret_interval!
>>
>> The problem is that change of  net.ipv4.route.secret_interval is change
>> nothing -- no matter that i set secret_interval from dfault 3600 to 2 or
>> 10000 i have always the same info about route cahce is disabled.
>> Also i change this parameter net.ipv4.rt_cache_rebuild_count from
>> default 4 to 9 and the same info - i try also change this to 12 but also
>> this change nothing.
>>
>> The machine that have this info is:
>> 2x Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
>> 12GB of RAM
>>
>>      
> Are you running a 64bit kernel ?
> What is your kernel version ?
>
> Please send :
>
> # grep . /proc/sys/net/ipv4/route/*
> #rtstat -c10 -i1
>
>    
Yes this is x86_64 kernel
i kernels  2.6.32.2 /  2.6.32.7 and now 2.6.33-rc6-git5 and on all 
kernels the same thing happens.
grep . /proc/sys/net/ipv4/route/*
/proc/sys/net/ipv4/route/error_burst:1250
/proc/sys/net/ipv4/route/error_cost:250
grep: /proc/sys/net/ipv4/route/flush: Permission denied
/proc/sys/net/ipv4/route/gc_elasticity:2
/proc/sys/net/ipv4/route/gc_interval:2
/proc/sys/net/ipv4/route/gc_min_interval:0
/proc/sys/net/ipv4/route/gc_min_interval_ms:500
/proc/sys/net/ipv4/route/gc_thresh:65535
/proc/sys/net/ipv4/route/gc_timeout:300
/proc/sys/net/ipv4/route/max_size:524288
/proc/sys/net/ipv4/route/min_adv_mss:256
/proc/sys/net/ipv4/route/min_pmtu:552
/proc/sys/net/ipv4/route/mtu_expires:600
/proc/sys/net/ipv4/route/redirect_load:5
/proc/sys/net/ipv4/route/redirect_number:9
/proc/sys/net/ipv4/route/redirect_silence:5120
/proc/sys/net/ipv4/route/secret_interval:2

This happens not all the time.
I have this info only when there are "internet rush hours" - thn there 
is about 700Mbit/s TX + 700Mbit/s RX forwarded traffic


>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>    


--------------010305020902080908090908
Content-Type: text/plain;
 name="rtstat.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="rtstat.txt"

cnRzdGF0IC1jMTAgLWkxDQpydF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxy
dF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxy
dF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxydF9jYWNoZXxy
dF9jYWNoZXwNCiBlbnRyaWVzfCAgaW5faGl0fGluX3Nsb3dffGluX3Nsb3dffGluX25vX3Jv
fCAgaW5fYnJkfGluX21hcnRpfGluX21hcnRpfCBvdXRfaGl0fG91dF9zbG93fG91dF9zbG93
fGdjX3RvdGFsfGdjX2lnbm9yfGdjX2dvYWxffGdjX2RzdF9vfGluX2hsaXN0fG91dF9obGlz
fA0KICAgICAgICB8ICAgICAgICB8ICAgICB0b3R8ICAgICAgbWN8ICAgICB1dGV8ICAgICAg
ICB8ICBhbl9kc3R8ICBhbl9zcmN8ICAgICAgICB8ICAgIF90b3R8ICAgICBfbWN8ICAgICAg
ICB8ICAgICAgZWR8ICAgIG1pc3N8IHZlcmZsb3d8IF9zZWFyY2h8dF9zZWFyY2h8DQogICAx
MjA4MnwzNDQwMjE3Mjk2fDY0NTY0MTM4NzN8ICAgICAgIDB8ICA2MjMwOTR8ICAgICAyOTR8
ICAgICAgIDB8ICAgICAgIDN8ICA3MzUxMTZ8IDU3MDEwNjJ8ICAgICAgIDB8MjYxMjYwNzM5
fDI2MTA0MDM2NXwgICAgICAgMHwgICAgICAgMHw2NTQ2MTc5NjF8ICAxNzkwNDR8DQogICAx
MDAzN3wgICAgICAgMHwgIDE1MjE0MnwgICAgICAgMHwgICAgICAgN3wgICAgICAgMHwgICAg
ICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgIDEyM3wgICAgICAgMHwgICAgICAgMHwgICAg
ICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwNCiAgIDEyMDMyfCAg
ICAgICAwfCAgMTU1NzcwfCAgICAgICAwfCAgICAgICA0fCAgICAgICAwfCAgICAgICAwfCAg
ICAgICAwfCAgICAgICAwfCAgICAgMTIyfCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAg
ICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfA0KICAgMTA5OTF8ICAgICAgIDB8
ICAxNjEwNDB8ICAgICAgIDB8ICAgICAgIDd8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8
ICAgICAgIDB8ICAgICAxMjl8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8
ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8DQogICAgOTg5OHwgICAgICAgMHwgIDE1NTUw
M3wgICAgICAgMHwgICAgICAgOXwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAg
MHwgICAgIDEyNXwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAg
MHwgICAgICAgMHwgICAgICAgMHwNCiAgIDEyNTUzfCAgICAgICAwfCAgMTU3NDU1fCAgICAg
ICAwfCAgICAgICA2fCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAg
MTI5fCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAg
ICAwfCAgICAgICAwfA0KICAgMTA5ODN8ICAgICAgIDB8ICAxNTc3NDJ8ICAgICAgIDB8ICAg
ICAgIDl8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAxMjh8ICAg
ICAgIDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8ICAg
ICAgIDB8DQogICAgOTM3NXwgICAgICAgMHwgIDE1ODIyNnwgICAgICAgMHwgICAgICAgOHwg
ICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgIDExNXwgICAgICAgMHwg
ICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwgICAgICAgMHwN
CiAgIDExOTI5fCAgICAgICAwfCAgMTU5MzQyfCAgICAgICAwfCAgICAgIDEwfCAgICAgICAw
fCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAgMTMwfCAgICAgICAwfCAgICAgICAw
fCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfCAgICAgICAwfA0KICAgMTEw
NDZ8ICAgICAgIDB8ICAxNTgwMTV8ICAgICAgIDB8ICAgICAgIDh8ICAgICAgIDB8ICAgICAg
IDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAxMjZ8ICAgICAgIDB8ICAgICAgIDB8ICAgICAg
IDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8ICAgICAgIDB8DQo=
--------------010305020902080908090908--
