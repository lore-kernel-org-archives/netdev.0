From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: What is SOF_TIMESTAMPING_RX_HARDWARE?
Date: Tue, 4 Mar 2014 09:45:08 -0800
Message-ID: <CALCETrWZ8kBFDMmUAjKrwndLWEo70OQv3rFSTXdLOyMGy-095Q@mail.gmail.com>
References: <CALCETrULL_QJqSLSCcySdUdj5sGgh8A7gyEn=vpgCC4LDjPHFA@mail.gmail.com>
 <20140304101030.GA8532@netboy> <CALCETrWa5NcTD+fAz1-Xf4hJPoQ=cG6Z44WMUukaWxe=kGB3kQ@mail.gmail.com>
 <20140304174200.GB4279@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:39458 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755163AbaCDSpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:45:09 -0500
Received: by mail-vc0-f175.google.com with SMTP id il7so527421vcb.34
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 10:45:08 -0800 (PST)
In-Reply-To: <20140304174200.GB4279@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 4, 2014 at 9:42 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Tue, Mar 04, 2014 at 09:21:47AM -0800, Andy Lutomirski wrote:
>>
>> In theory, the driver could stop reporting timestamps if
>> SOF_TIMESTAMPING_RAW_HARDWARE: and SOF_TIMESTAMPING_SYS_HARDWARE
>> aren't set.  I don't see why SOF_TIMESTAMPING_RX_HARDWARE would make
>> any sense in this context.
>
> AFAICT, the intent was that the former are handled by the stack, while
> the latter is handled by the driver.

I suspect that any attempt to implement this will break userspace --
there must be programs my now (like mine!) that set
SOF_TIMESTAMPING_SYS_HARDWARE but not SOF_TIMESTAMPING_RX_HARDWARE.

I'll write a documentation patch.

--Andy
