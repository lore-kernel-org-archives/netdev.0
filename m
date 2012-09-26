From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe unstable performance at 1Gb/s
Date: Wed, 26 Sep 2012 20:22:04 +0000
Message-ID: <87618083B2453E4A8714035B62D6799216E25F9C@FMSMSX102.amr.corp.intel.com>
References: <loom.20120924T193212-646@post.gmane.org>
 <87618083B2453E4A8714035B62D6799216E25153@FMSMSX102.amr.corp.intel.com>
 <50634A60.40609@unige.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Charles Vejnar <Charles.Vejnar@unige.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:28357 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945Ab2IZUWG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 16:22:06 -0400
In-Reply-To: <50634A60.40609@unige.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Charles Vejnar [mailto:Charles.Vejnar@unige.ch]
>Sent: Wednesday, September 26, 2012 11:33 AM
>To: Tantilov, Emil S; netdev@vger.kernel.org
>Subject: Re: ixgbe unstable performance at 1Gb/s
>
>Le 25/09/2012 19:58, Tantilov, Emil S a =E9crit :
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel=
=2Eorg]
>On
>>> Behalf Of Charles
>>> Sent: Monday, September 24, 2012 10:47 AM
>>> To: netdev@vger.kernel.org
>>> Subject: ixgbe unstable performance at 1Gb/s
>>>
>>> Hi,
>>>
>>> I hope I am posting on the right mailing-list. If not, sorry; pleas=
e
>>> redirect me
>>> to the right place. Thanks.
>>>
>>> I have a new motherboard with integrated Intel X540 10GBase-T. For =
now,
>I
>>> want
>>> to use it at 1Gb/s.
>>>
>>> The bandwidth is only of ~300 Mbit/s (with Iperf). It's actually ve=
ry
>>> unstable
>>> (always varies between 100 to 800 Mbit/s during the transfer).
>> Do you by any chance have CONFIG_IXGBE_PTP set in your kernel config=
?
>>
>> If so, try disabling it and see if it fixes your performance.
>>
>> Thanks,
>> Emil
>>
>Hi,
>
>Thanks for your reply.
>
>I compiled manually the ixgbe module with the default options of my
>distribution (Archlinux). I had the same problem.
>
>I then changed the CONFIG_IXGBE_PTP to no (default is yes) as you
>suggested, and recompiled. The problem disappeared; normal transfer.
>
>Could you please explain why this PTP is causing a problem? How can th=
is
>be fixed without having to recompile the module (ethtool, /sys, bios..=
=2E
>)? Thanks

This is actually a bug in the driver. We should have a patch out very s=
oon to address it.

>
>Regards,
>
>Charles

Thanks,
Emil
