From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][TG3]Some cleanups
Date: Sun, 07 Oct 2007 23:32:35 -0700 (PDT)
Message-ID: <20071007.233235.115620499.davem@davemloft.net>
References: <1191368033.5961.22.camel@dell>
	<1191417527.4357.25.camel@localhost>
	<1191769941.4394.1.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, mcarlson@broadcom.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751459AbXJHGcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 02:32:36 -0400
In-Reply-To: <1191769941.4394.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Sun, 07 Oct 2007 11:12:21 -0400

> Ok, attached patch against net-2.6.24 from this morning. I am setting up
> some equipment for testing as i type this - so i will test for any
> regressions. If you dont hear from me on the subject then all went ok.

This "cleanup" only makes sense if we go with your TX batching
interfaces.

They make the TX batching support patch for this driver "nice" and
"clean", but it makes zero sense in any other context.  In fact, it
adds more memory references in the TX pacth, and in fact does so by
adding usage of the skb->cb[] which the driver didn't need to do
previously.

So I'm going to hold off on this one for now, keep it in your TX
batching changes instead.

THanks.
