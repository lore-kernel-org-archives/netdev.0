From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Wed, 21 Nov 2012 23:53:11 -0500
Message-ID: <50ADAFB7.7070704@pobox.com>
References: <50AD1972.5080403@pobox.com> <1353529639.26346.164.camel@shinybook.infradead.org> <50ADA05B.2000308@pobox.com> <20121121.233945.2225341904551631404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, jasowang@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:51904 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab2KVUaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 15:30:25 -0500
Received: by mail-vc0-f174.google.com with SMTP id m18so5023451vcm.19
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 12:30:24 -0800 (PST)
In-Reply-To: <20121121.233945.2225341904551631404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2012 11:39 PM, David Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Wed, 21 Nov 2012 22:47:39 -0500
>
>> State A:  pre-b01af457, known working
>> State B:  b01af457, known broken
>
> State A is also known buggy on the largest consumer of this driver,
> the emulated hardware.
>
> Please evaluate this realistically.

If the simulator fails to match the hardware, that is a simulator bug.

It is disappointing to work around someone else's software bug in the 
kernel.

	Jeff
