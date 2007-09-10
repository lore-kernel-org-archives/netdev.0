From: =?iso-8859-15?q?Hans-J=FCrgen_Koch?= <hjk@linutronix.de>
Subject: Re: [PATCH resend] Fix a lock problem in generic phy code
Date: Mon, 10 Sep 2007 20:45:50 +0200
Message-ID: <200709102045.51063.hjk@linutronix.de>
References: <E1IUf6h-0006qu-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jeff@garzik.org, afleming@freescale.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:42877 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751063AbXIJSpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 14:45:53 -0400
In-Reply-To: <E1IUf6h-0006qu-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag 10 September 2007 schrieb Herbert Xu:
> Hans-J??rgen Koch <hjk@linutronix.de> wrote:
> > The following patch fixes it. Tested on an AT91SAM9263-EK board, kernel
> > 2.6.23-rc4 and -rc3-mm1.
>
> Could you please audit all instances of physdev->lock and add
> _bh where necessary?  I can see that at least phys_stop also
> needs the _bh.

I think the patch does all that's necessary. At least, there're no error
messages in the logs anymore. I didn't check if there's an error on
unload, though.

>
> We should also consider whether it makes sense to move the
> timer into a work queue.

Somebody who's more involved in that PHY stuff should probably do that.
I'm on holidays, sitting in a hotel room, and will probably not have the
time to have a deeper look into that.

Thanks,
Hans



