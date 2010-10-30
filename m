From: zic422@gmail.com
Subject: Re: [Bugme-new] [Bug 16350] New: RTL8103EL interface new tcp
 connections get stuck on SYN_SENT state after 10 hours uptime
Date: Sat, 30 Oct 2010 15:58:56 +0300
Message-ID: <AANLkTinTFxwKpc0zmQ7HZw8=QmLc2MKrJgWyQ6P6vCeW@mail.gmail.com>
References: <bug-16350-10286@https.bugzilla.kernel.org/>
	<20100708142526.5bf5938e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33710 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab0J3M66 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 08:58:58 -0400
Received: by wwe15 with SMTP id 15so4470704wwe.1
        for <netdev@vger.kernel.org>; Sat, 30 Oct 2010 05:58:56 -0700 (PDT)
In-Reply-To: <20100708142526.5bf5938e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now I cannot reproduce this bug. Don't know when it get banished. I
did not managed to reach more than ten hours uptime last two months.

On Fri, Jul 9, 2010 at 12:25 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> (switched to email. =C2=A0Please respond via emailed reply-to-all, no=
t via the
> bugzilla web interface).
>
> On Wed, 7 Jul 2010 14:04:59 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D16350
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: RTL8103EL interfac=
e new tcp connections get stuck on
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 SYN_SENT state after 10 hours uptime
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Networking
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> =C2=A0 =C2=A0 Kernel Version: 2.6.34.1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Platform: All
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 OS/Version: Linux
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Tree: Mainline
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Status: NEW
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Severity: normal
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Priority: P1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Component: IPV4
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 AssignedTo: shemminger@linux-foundation.=
org
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ReportedBy: zic422@gmail.com
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Regression: No
>>
>>
>> Created an attachment (id=3D27038)
>> =C2=A0--> (https://bugzilla.kernel.org/attachment.cgi?id=3D27038)
>> ioports, iomem, lspci, ver_linux and kernel config
>>
>> After 9-11 hours uptime network interface of RTL8103EL card cannot m=
ake new tcp
>> connections to internet and correctly close existing ones. ICMP and =
UDP works
>> fine. Besides r8169 driver I tried also the r8101-1.015.00 one from =
realtek
>> site with older kernel and bug were in place.
>>
>> Connections inside home network work normally. I tried to reboot rou=
ter but
>> nor reconnecting ethernet cable nor restarting network daemon nor re=
loading
>> kernel module does not make any help. Bug disappears only after rebo=
oting my
>> pc.
>>
>> repeatability of bug is 100% on arch, debian and gentoo
>>
>> default kernel config
>>
>> http://bugs.archlinux.org/task/19162 =C2=A0(this bug)
