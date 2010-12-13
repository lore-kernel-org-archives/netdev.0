From: Jesse Gross <jesse@nicira.com>
Subject: Re: set vlan CFI and TPID
Date: Mon, 13 Dec 2010 01:16:37 -0800
Message-ID: <AANLkTinxwdSvN5kcaj81SFGHKfQeRH9CE3aUzK+eZtWg@mail.gmail.com>
References: <AANLkTimW35xF4dcr_UO6XX1tBb3VBcp2PWPq8SkMk60=@mail.gmail.com>
	<AANLkTim3Rm91O2n6dCqTJYja8fy_sb0dKthCA1rf=FPV@mail.gmail.com>
	<AANLkTimRZezo4WYZiXfsra83AojMubrZap1d1r5KUst1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: hong zhiyi <zhiyi.hong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:34170 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756133Ab0LMJQj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 04:16:39 -0500
Received: by fxm18 with SMTP id 18so6000223fxm.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 01:16:38 -0800 (PST)
In-Reply-To: <AANLkTimRZezo4WYZiXfsra83AojMubrZap1d1r5KUst1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 12, 2010 at 6:20 PM, hong zhiyi <zhiyi.hong@gmail.com> wrot=
e:
> On Mon, Dec 13, 2010 at 8:20 AM, Jesse Gross <jesse@nicira.com> wrote=
:
>> On Tue, Dec 7, 2010 at 8:04 PM, hong zhiyi <zhiyi.hong@gmail.com> wr=
ote:
>>> Hi All,
>>>
>>> May I ask how to set the 1 bit CFI and 2 bytesTPID in the VLAN head=
er
>>> by vconfig?
>>
>> You can't change them using vconfig. =A0For 802.1q/Ethernet, the TPI=
D is
>> 0x8100 and the CFI is 0.
>>
>>> and what is the meaning of the egress map and ingress map?
>>
>> These convert between the PCP bits found in the vlan header and the
>> priority field that is used internally for QoS, which you access
>> through tc.
>>
>
> Hi Jesse,
>
> Thank you for your reply.
>
> Then how can it set the value of the TPID and the CFI? Also, I do not
> understand you mentioned the *tc* means, what is the tc?

You can't really.  Like I said, the values are fixed by the standard
for basic 802.1q, which is what Linux implements.  You could, of
course, directly send/receive packets through a raw socket with
whatever values you like.  However, other components of the kernel
that deal with vlans won't recognize them.

tc is a userspace program that (among other things) handles QoS
settings.  Google should be able to turn up information on how to use
it.
