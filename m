From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][TG3]Some cleanups
Date: Mon, 08 Oct 2007 09:42:03 -0400
Message-ID: <1191850923.4352.50.camel@localhost>
References: <1191368033.5961.22.camel@dell>
	 <1191417527.4357.25.camel@localhost> <1191769941.4394.1.camel@localhost>
	 <20071007.233235.115620499.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, mcarlson@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:10615 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbXJHNmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 09:42:24 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1322859wxd
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 06:42:23 -0700 (PDT)
In-Reply-To: <20071007.233235.115620499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-07-10 at 23:32 -0700, David Miller wrote:

> This "cleanup" only makes sense if we go with your TX batching
> interfaces.
>
> They make the TX batching support patch for this driver "nice" and
> "clean", but it makes zero sense in any other context.  
> In fact, it
> adds more memory references in the TX pacth, and in fact does so by
> adding usage of the skb->cb[] which the driver didn't need to do
> previously.
> 
> So I'm going to hold off on this one for now, keep it in your TX
> batching changes instead.

The batching benefits from it because it reuses code. But i would put
readability as something of no value. 
In any case i would defer this for later.

cheers,
jamal

