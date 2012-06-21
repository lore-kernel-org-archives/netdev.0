From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PTP + H/W time stamping + CONFIG_PREEMPT_RT_FULL == Oops in
 slab
Date: Thu, 21 Jun 2012 21:54:28 +0200
Message-ID: <20120621195428.GC13496@netboy.at.omicron.at>
References: <CAGgcXb662=PbdJaMff1QfBhW06mYXgNvM1o6snunZMe=Q36Q7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: satpal parmar <systems.satpal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34771 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756405Ab2FUTyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 15:54:39 -0400
Received: by bkcji2 with SMTP id ji2so964945bkc.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 12:54:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAGgcXb662=PbdJaMff1QfBhW06mYXgNvM1o6snunZMe=Q36Q7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I suspect this isn't a time stamping bug, but rather that the time
stamping code just triggers the issue. My own experience has been that
preempt_rt on arm is quite shaky.

On Thu, Jun 21, 2012 at 08:09:11PM +0530, satpal parmar wrote:
> I am not sure if this is the right mailing list. If anyone know better
> forum please direct me to that.  Appreciate your patience and time.

Maybe lkml or rt-users would be better.

However, there are really too many variables, and I recommend first
narrowing the problem down. Here are a few ideas.

1. use a mainline kernel plus rt patch (without vendor/custom changes)
2. try to trigger issue without using ptpd2 (like stress testing)
3. write a simple test case (like sending a single PTP sync) and
   instrument your kernel

Good luck,
Richard
