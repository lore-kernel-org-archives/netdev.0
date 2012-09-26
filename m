From: Charles Vejnar <Charles.Vejnar@unige.ch>
Subject: Re: ixgbe unstable performance at 1Gb/s
Date: Wed, 26 Sep 2012 20:33:04 +0200
Message-ID: <50634A60.40609@unige.ch>
References: <loom.20120924T193212-646@post.gmane.org>
 <87618083B2453E4A8714035B62D6799216E25153@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mc2.unige.ch ([129.194.9.215]:43758 "EHLO unige.ch"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757471Ab2IZSng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 14:43:36 -0400
Received: from mmp3.unige.ch ([129.194.7.203])
	by unige.ch stage1 with esmtp
	(Exim MailCleaner)
	id 1TGwPw-0006nP-Iw
	for <netdev@vger.kernel.org>
	from <Charles.Vejnar@unige.ch>; Wed, 26 Sep 2012 20:33:04 +0200
Received: from [129.194.101.63] (sancy.unige.ch [129.194.101.63])
 by mmp3.unige.ch
 (Oracle Communications Messaging Server 7u4-23.01(7.0.4.23.0) 64bit (built Aug
 10 2011)) with ESMTPSA id <0MAY00D5FZJ40X40@mmp3.unige.ch> for
 netdev@vger.kernel.org; Wed, 26 Sep 2012 20:33:04 +0200 (MEST)
In-reply-to: <87618083B2453E4A8714035B62D6799216E25153@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/09/2012 19:58, Tantilov, Emil S a =E9crit :
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org] On
>> Behalf Of Charles
>> Sent: Monday, September 24, 2012 10:47 AM
>> To: netdev@vger.kernel.org
>> Subject: ixgbe unstable performance at 1Gb/s
>>
>> Hi,
>>
>> I hope I am posting on the right mailing-list. If not, sorry; please
>> redirect me
>> to the right place. Thanks.
>>
>> I have a new motherboard with integrated Intel X540 10GBase-T. For n=
ow, I
>> want
>> to use it at 1Gb/s.
>>
>> The bandwidth is only of ~300 Mbit/s (with Iperf). It's actually ver=
y
>> unstable
>> (always varies between 100 to 800 Mbit/s during the transfer).
> Do you by any chance have CONFIG_IXGBE_PTP set in your kernel config?
>
> If so, try disabling it and see if it fixes your performance.
>
> Thanks,
> Emil
>
Hi,

Thanks for your reply.

I compiled manually the ixgbe module with the default options of my=20
distribution (Archlinux). I had the same problem.

I then changed the CONFIG_IXGBE_PTP to no (default is yes) as you=20
suggested, and recompiled. The problem disappeared; normal transfer.

Could you please explain why this PTP is causing a problem? How can thi=
s=20
be fixed without having to recompile the module (ethtool, /sys, bios...=
=20
)? Thanks

Regards,

Charles
