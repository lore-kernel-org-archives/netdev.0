From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [Bugme-new] [Bug 22962] New: building (e)glibc against 2.6.37-rc1
 headers fails
Date: Wed, 17 Nov 2010 07:59:52 +0800
Message-ID: <AANLkTikXYc=POSCHoypubZkFcXoU6mJbjUKcnAzKovyL@mail.gmail.com>
References: <bug-22962-10286@https.bugzilla.kernel.org/> <20101116143349.2fbb6ed8.akpm@linux-foundation.org>
 <4CE310A7.2060302@openelec.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephan Raue <stephan@openelec.tv>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39730 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755966Ab0KQAAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 19:00:14 -0500
Received: by eye27 with SMTP id 27so821328eye.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 16:00:13 -0800 (PST)
In-Reply-To: <4CE310A7.2060302@openelec.tv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 17, 2010 at 7:15 AM, Stephan Raue <stephan@openelec.tv> wrote:
> Hi,
>
>
> Am 16.11.2010 23:33, schrieb Andrew Morton:
>> Maybe we need some __KERNEL__ guards in if.h.
>>
> in the meantime i can build with attached patch.
>

I checked the source code of linux/if.h in my Gentoo, and found the
conflict structures are renamed with __kernel_ prefix. Some changes in
linux/if.h is needed maybe.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
