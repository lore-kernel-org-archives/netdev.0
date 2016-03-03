From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH 6/8] x86: tsc: Always Running Timer (ART) correlated clocksource
Date: Thu, 3 Mar 2016 14:24:38 -0800
Message-ID: <CALAqxLWFDg6U4mTuZWuWnW8C3QsaxKzazQ_2hhx15Bf7w8uUQw@mail.gmail.com>
References: <1456978919-30076-1-git-send-email-john.stultz@linaro.org>
	<1456978919-30076-7-git-send-email-john.stultz@linaro.org>
	<alpine.DEB.2.11.1603031118430.3597@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: lkml <linux-kernel@vger.kernel.org>,
	"Christopher S. Hall" <christopher.s.hall@intel.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>,
	kevin.j.clarke@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33878 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757565AbcCCWYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:24:39 -0500
Received: by mail-yk0-f176.google.com with SMTP id u9so15695403ykd.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 14:24:38 -0800 (PST)
In-Reply-To: <alpine.DEB.2.11.1603031118430.3597@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 2:21 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Wed, 2 Mar 2016, John Stultz wrote:
>
> Subject: x86: tsc: Always Running ...
>
> Please make that:
>
> Subject: x86/tsc: Always Running ...

Will do.

>
>>
>> +#else
>> +
>> +#define detect_art()
>
> Inline stub if at all. Why sits detect_art() under CONFIG_CPU_FREQ while the
> rest of the art code is not????

Ok. Just double checked with Christopher and the code is ok to move
out from CONFIG_CPU_FREQ.

I'll respin and resend the set later today.

thanks
-john
