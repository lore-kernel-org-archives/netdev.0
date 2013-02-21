From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Thu, 21 Feb 2013 16:04:46 -0300
Message-ID: <CAOMZO5DhSJxrd8GjZOq2nsF5nPNubzvHawkG2hWranQ64FSHHQ@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<kepftg$f3c$1@ger.gmane.org>
	<CAHrpEqQMZNmzRrNQK60hokR2r5S=U65YdC-5h6aHHHzAVdEWKw@mail.gmail.com>
	<loom.20130221T175907-606@post.gmane.org>
	<CAOMZO5AJa7fs+VdA8jGE5mDnxp4ZQ6a9CjbSou5J+RA3uXUjxQ@mail.gmail.com>
	<loom.20130221T185110-574@post.gmane.org>
	<CAOMZO5DqzNUvfmRxPZAhk4i_+SKbTthHqTkQCvW7K+8o7b42zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Li Frank-B20596 <B20596@freescale.com>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:50545 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab3BUTEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 14:04:47 -0500
Received: by mail-wi0-f180.google.com with SMTP id hi8so19454wib.13
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 11:04:46 -0800 (PST)
In-Reply-To: <CAOMZO5DqzNUvfmRxPZAhk4i_+SKbTthHqTkQCvW7K+8o7b42zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 3:04 PM, Fabio Estevam <festevam@gmail.com> wrote:
> On Thu, Feb 21, 2013 at 2:59 PM, Jim Baxter <jim_baxter@mentor.com> wrote:
>
>> That is a good patch that will stop interrupts occurring before request_irq is
>> called.
>>
>> What about the problem of fec_enet_interrupt calling fec_ptp_start_cyclecounter
>> before fec_ptp_init has been called?
>>
>> Should fec_enet_init and fec_ptp_init be setup before the request_irq is called?
>
> Yes, I think so. Care to submit a patch?

Ok, I prepared a patch with this fix and will submit shortly.
