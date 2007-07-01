From: "Dhananjay Phadke" <dhananjay.phadke@gmail.com>
Subject: Re: [PATCH 3/3] NetXen: Graceful teardown of interface and hardware upon module unload
Date: Sun, 1 Jul 2007 07:19:13 +0530
Message-ID: <ab901500706301849h5f8e25c7k8e2c0a8f04dd3198@mail.gmail.com>
References: <20070630203844.256007454@netxen.com>
	 <20070630204424.876510236@netxen.com>
	 <200707010012.11527.mb@bu3sch.de> <4686DC81.5090908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>, netdev@vger.kernel.org,
	rob@netxen.com, "Milan Bag" <mbag@netxen.com>,
	"Wen Xiong" <wenxiong@us.ibm.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:37549 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754413AbXGABtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 21:49:14 -0400
Received: by an-out-0708.google.com with SMTP id d31so257494and
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2007 18:49:13 -0700 (PDT)
In-Reply-To: <4686DC81.5090908@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This stage is safe to bail out on signal. It's initializing about a
hundred registers
and trying to guaranty by retrying, so can get stretched too much on faulty h/w.

-Dhananjay

On 7/1/07, Jeff Garzik <jeff@garzik.org> wrote:
> While strictly this is true, I strongly urge the use of
> non-interruptible sleeps when used in hardware-related delays.  Very
> rarely does one really want to care about signals for such cases.
>
>         Jeff
