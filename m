From: Grant Grundler <grundler@google.com>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Mon, 24 Mar 2014 12:27:53 -0700
Message-ID: <CANEJEGt_oDAh+WzBUCJ9+4bPOwaUswJSUh4tes1oxVGaRz5JeA@mail.gmail.com>
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
Received: from mail-ob0-f178.google.com ([209.85.214.178]:40492 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671AbaCXT1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 15:27:54 -0400
Received: by mail-ob0-f178.google.com with SMTP id wp18so6388398obc.9
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 12:27:54 -0700 (PDT)
In-Reply-To: <1395390825.5171.3.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2014 at 1:33 AM, Oliver Neukum <oneukum@suse.de> wrote:
...
> Very well. Thorough testing is good. I'll wait for the result. Could
> you notify me of the final outcome?

Ship it. :)

The testing so far has completed over 15K iterations of unload/reload
of the asix driver on the original failing system with no failures so
far. Previously I could reproduce the problem in 2K-8K iterations.

The caveat is due to various issues with my test environment, the test
never ran more than 7K iterations continuously. The ~15k is spread out
across four invocations (2K, 3K, 7K, 4K) of the previously shared
"for" loop.

Please add my Reported-by + Tested-by to this patch.

thanks
grant
