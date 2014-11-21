From: Tom Herbert <therbert@google.com>
Subject: Re: Translation table available between 'ethtool -k' and 'ethtool -K'
 ? For Linux?
Date: Thu, 20 Nov 2014 17:07:44 -0800
Message-ID: <CA+mtBx9SJ5mhLBMk8E0gGceweMyzJ2icBfjGJc0rjOTDVQZi1Q@mail.gmail.com>
References: <BABF60987D48764FA4071AC73CB9C56162EBFBD0AC@AUSX7MCPC101.AMER.DELL.COM>
	<1416526354.7215.4.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Spike_White@dell.com, Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:50965 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756792AbaKUBHp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 20:07:45 -0500
Received: by mail-ie0-f172.google.com with SMTP id ar1so3986128iec.31
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 17:07:45 -0800 (PST)
In-Reply-To: <1416526354.7215.4.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 3:32 PM, Ben Hutchings <ben@decadent.org.uk> wr=
ote:
> On Thu, 2014-11-20 at 15:10 -0600, Spike_White@Dell.com wrote:
>> Ethtool developers,
>>
>>
>>
>> Is there a translation table available between the offload names tha=
t
>> ethtool =E2=80=93k reports and the offload names that ethool =E2=80=93=
K accepts?
>>
>>
>>
>> Our network engineering team has to standard to disable all NIC
>> offloads.  I don=E2=80=99t disagree;  several have often bitten us i=
n the
>> past.  LRO on vmxnet3 vNICs, TSO on old NICs and (just now) LRO on
>> ixgbe/Intel NIC.
>
> So instead of properly validating drivers, you just assume they all h=
ave
> the same bug as something you saw in the past?
>
> You may think you're being conservative, but by using non-default
> settings you're actually taking more of a risk.
>
Ben I'm not sure I see this. If we turn off HW offloads and rely on
the software offloads where is the increased risk? This may result in
performance degradation for sure, but I really hope at this point that
the software offload mechanisms in the stack are as least as robust as
any HW mechanism.

>> And we have CPU for days, never CPU-limited on our servers.
>
> Lucky you.  It's a shame about the power going to waste.
>
>> If ethtool =E2=80=93K accepted the offload format that =E2=80=93k re=
ports, then
>> disabling all offloads would be trivial:
> [...]
>> Is there a translation table somewhere that translates from the =E2=80=
=98-k=E2=80=99
>> output offload names to the =E2=80=98-K=E2=80=99 style offload names=
?
> [...]
>
> Yes, it's the off_flag_def array.
>
> For any newly defined features, ethtool will simply use the name
> supplied by the kernel for both -k output and -K argument parsing.
>
> Ben.
>
> --
> Ben Hutchings
> Man invented language to satisfy his deep need to complain. - Lily To=
mlin
