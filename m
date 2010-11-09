From: Luke Hutchison <luke.hutch@gmail.com>
Subject: Re: Networking hangs when too many parallel requests are made at once
Date: Tue, 9 Nov 2010 16:17:28 -0500
Message-ID: <AANLkTinu4=Ox_vA_yr7vbdbcqr4P7oS+zMX_yaXhK4E9@mail.gmail.com>
References: <AANLkTikuCj=saH34dyO6xnU-y8rWv63hJaqowZ0ACLzk@mail.gmail.com>
 <AANLkTinRo_ozWFCYYqanOh0YrTJ6+KadutG2j7T726dY@mail.gmail.com>
 <4CD99E20.4060307@candelatech.com> <AANLkTinz6C4s3wX7t6CsE2bzZ2adCoi0RAcqvpEFE2GV@mail.gmail.com>
 <4CD9B09B.8040906@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:54472 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab0KIVSJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 16:18:09 -0500
Received: by gyh4 with SMTP id 4so4697859gyh.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 13:18:08 -0800 (PST)
In-Reply-To: <4CD9B09B.8040906@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 9, 2010 at 3:35 PM, Ben Greear <greearb@candelatech.com> wr=
ote:
> On 11/09/2010 12:27 PM, Luke Hutchison wrote:
>> No, I haven't been able to reproduce on any other machine. =C2=A0But=
 it
>> happens on both my wifi NIC and my ethernet NIC in this machine.
>
> Well, let us know what those are, at least.

=46rom my first email:

> I have a Toshiba Satellite Pro S300M-S2142
> laptop with a Core 2 Duo P8600 CPU, Intel GM45 gfx,
> Intel 82567V Gigabit Ethernet and Intel 5100 Wifi,
> running kernel kernel-2.6.36-1.1.fc15.x86_64 on top
> of Fedora 14.

On Tue, Nov 9, 2010 at 3:35 PM, Ben Greear <greearb@candelatech.com> wr=
ote:
> And, a network capture of your system going into this state might
> be useful. =C2=A0I'd try to disable your wireless NIC entirely and fo=
cus
> on debugging the wired NIC as that is usually easier to debug.

Sure -- a wireshark trace is here: http://web.mit.edu/~luke_h/www/trace=
=2Ebz2

In this particular trace, I opened about 20 browser tabs at once.
They all locked up after about 5 seconds.  A few of them loaded some
more content after a minute or two.  A minute or two later, I killed
them all.  In this particular example, pinging to a specific domain
name continued to work (it doesn't always), although I couldn't get
content from the domains in question: e.g. I could ping google.com,
but opening a new tab and trying to visit google.com caused the new
tab to hang too.

Thanks,
Luke
