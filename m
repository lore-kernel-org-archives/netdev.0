From: hong zhiyi <zhiyi.hong@gmail.com>
Subject: Re: set vlan CFI and TPID
Date: Mon, 13 Dec 2010 10:20:58 +0800
Message-ID: <AANLkTimRZezo4WYZiXfsra83AojMubrZap1d1r5KUst1@mail.gmail.com>
References: <AANLkTimW35xF4dcr_UO6XX1tBb3VBcp2PWPq8SkMk60=@mail.gmail.com>
	<AANLkTim3Rm91O2n6dCqTJYja8fy_sb0dKthCA1rf=FPV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:54355 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756586Ab0LMCU7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 21:20:59 -0500
Received: by gyb11 with SMTP id 11so2756569gyb.19
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 18:20:58 -0800 (PST)
In-Reply-To: <AANLkTim3Rm91O2n6dCqTJYja8fy_sb0dKthCA1rf=FPV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 8:20 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Tue, Dec 7, 2010 at 8:04 PM, hong zhiyi <zhiyi.hong@gmail.com> wro=
te:
>> Hi All,
>>
>> May I ask how to set the 1 bit CFI and 2 bytesTPID in the VLAN heade=
r
>> by vconfig?
>
> You can't change them using vconfig. =A0For 802.1q/Ethernet, the TPID=
 is
> 0x8100 and the CFI is 0.
>
>> and what is the meaning of the egress map and ingress map?
>
> These convert between the PCP bits found in the vlan header and the
> priority field that is used internally for QoS, which you access
> through tc.
>

Hi Jesse,

Thank you for your reply.

Then how can it set the value of the TPID and the CFI? Also, I do not
understand you mentioned the *tc* means, what is the tc?

Best Regards
Hong Zhiyi
