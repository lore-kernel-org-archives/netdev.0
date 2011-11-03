From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH] tg3: fix error handling in tg3_open
Date: Fri, 4 Nov 2011 06:23:11 +0900
Message-ID: <CAC5umyi2Z5aVpqsrA=JeQDTL9rJbS-ESUVJ128h55mY_orOrbQ@mail.gmail.com>
References: <1320316603-8355-1-git-send-email-akinobu.mita@gmail.com>
	<20111103191953.GA11186@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41320 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab1KCVXM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 17:23:12 -0400
Received: by vcge1 with SMTP id e1so1553321vcg.19
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2011 14:23:12 -0700 (PDT)
In-Reply-To: <20111103191953.GA11186@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/4 Matt Carlson <mcarlson@broadcom.com>:
> On Thu, Nov 03, 2011 at 03:36:43AM -0700, Akinobu Mita wrote:
>> If one of the request_irq calls fails in tg3_open, all interrupts
>> allocated with request_irq should be freed before returning error.
>>
>> But it accidentally attempts to free the same invalid IRQ repeatedly=
=2E
>
> Hi Akinobu. =A0I have a similar patch under internal review at this v=
ery
> minute. =A0The patch I have does a minor additional cleanup. =A0(It m=
oves
> the 'goto err_out2' inside the 'if (err)' block.) =A0Is it O.K.
> with you to add your SOB to my patch instead?

Sounds good.  Could you send the patch after finishing your review?
