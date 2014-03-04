From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: What is SOF_TIMESTAMPING_RX_HARDWARE?
Date: Tue, 4 Mar 2014 18:42:01 +0100
Message-ID: <20140304174200.GB4279@netboy>
References: <CALCETrULL_QJqSLSCcySdUdj5sGgh8A7gyEn=vpgCC4LDjPHFA@mail.gmail.com>
 <20140304101030.GA8532@netboy>
 <CALCETrWa5NcTD+fAz1-Xf4hJPoQ=cG6Z44WMUukaWxe=kGB3kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:49119 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbaCDRmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 12:42:12 -0500
Received: by mail-ee0-f50.google.com with SMTP id c13so3030002eek.9
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 09:42:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrWa5NcTD+fAz1-Xf4hJPoQ=cG6Z44WMUukaWxe=kGB3kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 04, 2014 at 09:21:47AM -0800, Andy Lutomirski wrote:
> 
> In theory, the driver could stop reporting timestamps if
> SOF_TIMESTAMPING_RAW_HARDWARE: and SOF_TIMESTAMPING_SYS_HARDWARE
> aren't set.  I don't see why SOF_TIMESTAMPING_RX_HARDWARE would make
> any sense in this context.

AFAICT, the intent was that the former are handled by the stack, while
the latter is handled by the driver.

Thanks,
Richard
