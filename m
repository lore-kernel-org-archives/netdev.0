From: Charles Vejnar <Charles.Vejnar@unige.ch>
Subject: Re: ixgbe unstable performance at 1Gb/s
Date: Thu, 27 Sep 2012 10:32:59 +0200
Message-ID: <50640F3B.6030102@unige.ch>
References: <loom.20120924T193212-646@post.gmane.org>
 <87618083B2453E4A8714035B62D6799216E25153@FMSMSX102.amr.corp.intel.com>
 <50634A60.40609@unige.ch>
 <87618083B2453E4A8714035B62D6799216E25F9C@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mc1.unige.ch ([129.194.9.214]:59105 "EHLO unige.ch"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751316Ab2I0IdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 04:33:02 -0400
Received: from mmp3.unige.ch ([129.194.7.203])
	by unige.ch stage1 with esmtp
	(Exim MailCleaner)
	id 1TH9Wl-0004i7-HA
	for <netdev@vger.kernel.org>
	from <Charles.Vejnar@unige.ch>; Thu, 27 Sep 2012 10:32:59 +0200
Received: from [129.194.101.63] (sancy.unige.ch [129.194.101.63])
 by mmp3.unige.ch
 (Oracle Communications Messaging Server 7u4-23.01(7.0.4.23.0) 64bit (built Aug
 10 2011)) with ESMTPSA id <0MB000DTM2EZ0XE0@mmp3.unige.ch> for
 netdev@vger.kernel.org; Thu, 27 Sep 2012 10:32:59 +0200 (MEST)
In-reply-to: <87618083B2453E4A8714035B62D6799216E25F9C@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/09/2012 22:22, Tantilov, Emil S a =E9crit :
>> -----Original Message-----
>> From: Charles Vejnar [mailto:Charles.Vejnar@unige.ch]
>> Sent: Wednesday, September 26, 2012 11:33 AM
>> To: Tantilov, Emil S; netdev@vger.kernel.org
>> Subject: Re: ixgbe unstable performance at 1Gb/s
>>
>> Le 25/09/2012 19:58, Tantilov, Emil S a =E9crit :
>>>> -----Original Message-----
>>>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kerne=
l.org]
>> On
>>>> Behalf Of Charles
>>>> Sent: Monday, September 24, 2012 10:47 AM
>>>> To: netdev@vger.kernel.org
>>>> Subject: ixgbe unstable performance at 1Gb/s
>>>>
>>>> Hi,
>>>>
>>>> I hope I am posting on the right mailing-list. If not, sorry; plea=
se
>>>> redirect me
>>>> to the right place. Thanks.
>>>>
>>>> I have a new motherboard with integrated Intel X540 10GBase-T. For=
 now,
>> I
>>>> want
>>>> to use it at 1Gb/s.
>>>>
>>>> The bandwidth is only of ~300 Mbit/s (with Iperf). It's actually v=
ery
>>>> unstable
>>>> (always varies between 100 to 800 Mbit/s during the transfer).
>>> Do you by any chance have CONFIG_IXGBE_PTP set in your kernel confi=
g?
>>>
>>> If so, try disabling it and see if it fixes your performance.
>>>
>>> Thanks,
>>> Emil
>>>
>> Hi,
>>
>> Thanks for your reply.
>>
>> I compiled manually the ixgbe module with the default options of my
>> distribution (Archlinux). I had the same problem.
>>
>> I then changed the CONFIG_IXGBE_PTP to no (default is yes) as you
>> suggested, and recompiled. The problem disappeared; normal transfer.
>>
>> Could you please explain why this PTP is causing a problem? How can =
this
>> be fixed without having to recompile the module (ethtool, /sys, bios=
=2E..
>> )? Thanks
> This is actually a bug in the driver. We should have a patch out very=
 soon to address it.
>
>> Regards,
>>
>> Charles
> Thanks,
> Emil
Hi Emil,

 > This is actually a bug in the driver. We should have a patch out ver=
y=20
soon to address it.

OK. Please send a reply to this thread when it's available. I can test=20
the patch.

Thanks

Charles
