From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Fri, 1 Jul 2011 10:01:07 +0400
Message-ID: <BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	<20110629145135.5179fb0c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47392 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718Ab1GAGBI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:01:08 -0400
Received: by vws1 with SMTP id 1so2145624vws.19
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 23:01:08 -0700 (PDT)
In-Reply-To: <20110629145135.5179fb0c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2011 at 01:51, Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> (switched to email. =C2=A0Please respond via emailed reply-to-all, no=
t via the
> bugzilla web interface).
>
> On Thu, 23 Jun 2011 17:33:54 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D38102
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Summary: BUG kmalloc-2048: =
Poison overwritten
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Product: Drivers
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Version: 2.5
>> =C2=A0 =C2=A0 Kernel Version: 3.0.0-rc4
>
> Looks like a 2.6.38->2.6.39 regression, perhaps a memory scribble in =
b44.

Actually, not sure about the version. 39 was the first one I've been
using in the scenario. Checking older versions now.
And git-log does not show a lot of changes to the b44 driver, so it
might be something unrelated.
