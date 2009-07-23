From: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe in
	back trace (regression)
Date: Thu, 23 Jul 2009 14:39:29 +0800
Message-ID: <43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: for.poige+bugzilla.kernel.org@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:49711 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbZGWGju convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 02:39:50 -0400
Received: by gxk9 with SMTP id 9so1349903gxk.13
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2009 23:39:49 -0700 (PDT)
In-Reply-To: <20090722134557.2457c5f5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/7/23 Andrew Morton <akpm@linux-foundation.org>:
>
> (switched to email. =C2=A0Please respond via emailed reply-to-all, no=
t via the
> bugzilla web interface).
>
> On Sat, 11 Jul 2009 06:10:00 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D13760
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: 2.6.30 kernel lock=
s up with pppoe in back trace
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 (regression)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Networking
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> =C2=A0 =C2=A0 Kernel Version: 2.6.30
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Platform: All
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 OS/Version: Linux
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Tree: Mainline
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: NEW
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Severity: normal
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Priority: P1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Component: Other
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 AssignedTo: acme@ghostprotocols.net
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ReportedBy: for.poige+bugzilla.kernel.or=
g@gmail.com
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Regression: Yes
>>
>>
>> Having updated kernel to 2.6.30 (and 2.6.30.1) I've faced several lo=
ck-ups
>> during boot sequence (and even during shutdown), when pppoe connecti=
on had been
>> initiated (and interrupted on shutdown). The lock-ups aren't Alt_Sys=
Rq_B
>> breakable.
>>
>> I still not have backtraces saved but as soon as pppoe connection in=
itiation
>> runs before running X-server (and after its shutdown), I have seen p=
arts of
>> dmesg's output and to my surprise it was regarding pppoe's functions=
=2E
>>
>
> This regression report is nearly two weeks old and I think there has
> been a bit of ppp-related fixing going on in that time.
>
> Can you please tell us whether the regression is still present in
> 2.6.30.2? =C2=A0If so, I expect we'll be wanting to see those traces,
> please.
>
	Just repeating the same thing I had written in the Bugzilla: I
haven't noticed any changes to pppoe during last commits to 2.6.30.
Why do you think there's a chance that bug(s) would have been fixed?

--=20
End of message. Next message?
