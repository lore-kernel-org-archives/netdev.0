From: Grant Grundler <grundler@google.com>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Fri, 21 Mar 2014 09:18:58 -0700
Message-ID: <CANEJEGu3dB5Hc=Zjrf4jMuzHGqOuJem2k3Y0YorFF98EGV7hiA@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<1394529263.16128.6.camel@linux-fkkt.site>
	<CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	<CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	<1395093343.3961.2.camel@linux-fkkt.site>
	<CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
	<CAODwPW-E-3HcXCGEmp9JpW6hU-Xt-FHwBtqeSSTDGaRPqO49Sw@mail.gmail.com>
	<CANEJEGscbVF3gRLNtTAcRSpHGVm1iDDKEeBscXcwj2-YdkiDXA@mail.gmail.com>
	<CANEJEGtZF30=bqkErvi1CFZLbk=PJ-p_gKf9eBGU7sWwJcrefg@mail.gmail.com>
	<1395299705.5432.12.camel@linux-fkkt.site>
	<CANEJEGu3j4a6LOiyD-Qbs5nX4wc4spWQB3ZukmEa1J6VPUg+=g@mail.gmail.com>
	<CANEJEGues6qVUEpWR5ggejg7dmS1PqzOHvZeWdxGJSnJh6c8Tw@mail.gmail.com>
	<1395390825.5171.3.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>,
	Julius Werner <jwerner@chromium.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:55435 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369AbaCUQS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 12:18:58 -0400
Received: by mail-oa0-f45.google.com with SMTP id eb12so2458657oac.32
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 09:18:58 -0700 (PDT)
In-Reply-To: <1395390825.5171.3.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2014 at 1:33 AM, Oliver Neukum <oneukum@suse.de> wrote:
...
> Very well. Thorough testing is good. I'll wait for the result. Could
> you notify me of the final outcome?

Ceratinly. Bad news is I had to restart my workstation that was
driving the test due to completely different issue (loopbacks hung -
known bug). reload_asix ran about 2000 iterations with no problems on
AX88178 part.
It's running again now on the same target machine.

> And, Julius, I owe you an apology. The check is necessary.

++oliver

Sorry to harp on this more, but I still think a comment is warranted:
  e.g. "Don't resend packets during shutdown of this USB net device."

And instead of naming the queue "wait", call the field "shutdown queue".

cheers,
grant
