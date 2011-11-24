From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3 03/10] net: Add netdev interfaces recording send/compl
Date: Wed, 23 Nov 2011 16:32:42 -0800
Message-ID: <CA+mtBx-VSJ6U2SyUxQt7eK9+cXFFAEQXgmhc+yWwpTX8zd6TJA@mail.gmail.com>
References: <20111123094614.36560215@nehalam.linuxnetplumber.net>
	<20111123.185812.1721878183759040757.davem@davemloft.net>
	<20111123160320.76143e3b@nehalam.linuxnetplumber.net>
	<20111123.190623.2026426589805797580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:52735 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109Ab1KXAco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 19:32:44 -0500
Received: by yenq3 with SMTP id q3so2000060yen.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 16:32:43 -0800 (PST)
In-Reply-To: <20111123.190623.2026426589805797580.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I was referring to the transmit routine, there for netdev_sent_queue()
>> is always called with one packet.
>
> Optimism for the future? :-)
>

Yep, I am looking forward to the day that someone figures out how to
batch transmits in a meaningful way!

> But yeah if nobody batches right now, no reason to support this in the
> interfaces, we can add it later.

Okay.

>
