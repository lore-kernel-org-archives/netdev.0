From: "David S. Miller" <davem@davemloft.net>
Subject: Re: fixing sk_stream_rfree()
Date: Mon, 17 Apr 2006 13:29:04 -0700 (PDT)
Message-ID: <20060417.132904.55913090.davem@davemloft.net>
References: <20060416111831.GA15093@gondor.apana.org.au>
	<20060416.223203.47773632.davem@davemloft.net>
	<20060417061700.GA21709@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61370
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751000AbWDQU2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 16:28:44 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060417061700.GA21709@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 17 Apr 2006 16:17:00 +1000

> On Sun, Apr 16, 2006 at 10:32:03PM -0700, David S. Miller wrote:
> > So it nearly has to be a send side issue that can only trigger with
> > TSO enabled, and my next planned chore is to audit the TSO splitting
> > during ACK processing.  We may be doing something stupid there.
> 
> BTW, do we have a dmesg log from the machine that did this with tg3?

I don't know, Jesse do you have it?

Jesse, my previously lead was a dead end, we're looking into other
possibilities, so if you have the kernel log from reproducing this
BUG(!sk_forward_alloc) problem with tg3 it would be very valuable at
this point.

Thanks.
