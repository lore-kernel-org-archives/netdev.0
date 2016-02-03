From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: ixgbe: get link speed as a slave nic unrelated with link
Date: Wed, 3 Feb 2016 18:17:48 +0800
Message-ID: <56B1D3CC.4050202@gmail.com>
References: <1452258030-63996-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <1454311675-24676-1-git-send-email-zyjzyj2000@gmail.com>
 <87618083B2453E4A8714035B62D67992505210DB@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Schmitt, Phillip J" <phillip.j.schmitt@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35812 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbcBCKRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:17:21 -0500
Received: by mail-pa0-f49.google.com with SMTP id ho8so11307069pac.2
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:17:21 -0800 (PST)
In-Reply-To: <87618083B2453E4A8714035B62D67992505210DB@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Emil

Thanks for your reply.

I made simple tests. And maybe this patch should work. Because you can
reproduce this problem, would you like to make tests with this patch?

If this patch can fix this problem, it can prove that the root cause is=
=20
correct.
We can find another solution to fix this problem.

If this patch can not fix this problem, maybe we should make further=20
investigations
to find the root cause.

Thanks a lot.
Zhu Yanjun

On 02/01/2016 11:53 PM, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: zyjzyj2000@gmail.com [mailto:zyjzyj2000@gmail.com]
>> Sent: Sunday, January 31, 2016 11:28 PM
>> To: zyjzyj2000@gmail.com; Tantilov, Emil S; Schmitt, Phillip J; Kirs=
her,
>> Jeffrey T; netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net=
;
>> Shteinbock, Boris (Wind River)
>> Subject: ixgbe: get link speed as a slave nic unrelated with link
>>
>>
>> Hi, Emil
>>
>> Thanks for your patch.
>> After I applied your patch, the following are the feedback from my u=
sers.
>>
>> "
>> Users had tested the latest patch that you provided and it is much i=
mproved
>> now. However it=E2=80=99s still not good enough as the users are pla=
nning field
>> deployment. Here are their findings:
>>
>> So close, but not quite 100%. I did run over 2500 re-negotiations on=
 one
>> interface of a bonded pair and got the 0 MBps status total of three =
times.
>> The longest run without single error was something like 1800 re-
>> negotiations or so. So, this version seems to improve the situation
>> immensely (the unpatched driver fails like 25% of the time), but the=
re
>> still seems to remain some tiny race somewhere.
> Yes at the time of the bonding interface coming up there can be a mes=
sage about 0 Mbps in dmesg,
> however the actual bond once fully up will have the correct speeds as=
 seen by:
> #cat /proc/net/bonding/bond0
>
> Thanks,
> Emil
>
>
