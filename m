From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Thu, 21 Feb 2013 15:04:21 -0300
Message-ID: <CAOMZO5DqzNUvfmRxPZAhk4i_+SKbTthHqTkQCvW7K+8o7b42zg@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<kepftg$f3c$1@ger.gmane.org>
	<CAHrpEqQMZNmzRrNQK60hokR2r5S=U65YdC-5h6aHHHzAVdEWKw@mail.gmail.com>
	<loom.20130221T175907-606@post.gmane.org>
	<CAOMZO5AJa7fs+VdA8jGE5mDnxp4ZQ6a9CjbSou5J+RA3uXUjxQ@mail.gmail.com>
	<loom.20130221T185110-574@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Li Frank-B20596 <B20596@freescale.com>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:41641 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756216Ab3BUSEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 13:04:23 -0500
Received: by mail-wi0-f179.google.com with SMTP id ez12so7951815wid.6
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 10:04:22 -0800 (PST)
In-Reply-To: <loom.20130221T185110-574@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 2:59 PM, Jim Baxter <jim_baxter@mentor.com> wrote:

> That is a good patch that will stop interrupts occurring before request_irq is
> called.
>
> What about the problem of fec_enet_interrupt calling fec_ptp_start_cyclecounter
> before fec_ptp_init has been called?
>
> Should fec_enet_init and fec_ptp_init be setup before the request_irq is called?

Yes, I think so. Care to submit a patch?
