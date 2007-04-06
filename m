From: "Antonino A. Daplas" <adaplas@pol.net>
Subject: Re: [SC92031]: Fix priv->lock context
Date: Fri, 6 Apr 2007 09:10:05 +0800 (PHT)
Message-ID: <41624.10.250.10.1.1175821805.squirrel@webmail.medscape.com>
References: <20070404190402.609cbd65.akpm@linux-foundation.org>
        <20070405114431.GA10972@gondor.apana.org.au>
        <20070405.095929.79068467.davem@davemloft.net>
        <20070405215703.GA21219@gondor.apana.org.au>
Reply-To: adaplas@pol.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <davem@davemloft.net>, <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <adaplas@pol.net>, <jgarzik@pobox.com>
To: <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf01.pol.net ([63.240.86.10]:38177 "EHLO sf01.pol.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767366AbXDFBP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 21:15:58 -0400
In-Reply-To: <20070405215703.GA21219@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thu, Apr 05, 2007 at 09:59:29AM -0700, David Miller wrote:
>>
>> Where is the patch? :-)
>>
>> Second time you've done this in two days Herbert, tsk tsk :)))
>
> The patch was so easy that it was left as an exercise to the reader :)

I did try, but it was too much for me :-)

>
> [SC92031]: Fix priv->lock context
>
> The spin_lock calls made in dev->open and dev->close must disable
> BH since open/close are made in process context.  Conversely, the
> call in dev->hard_start_xmit does not need to disable BH since it
> is already executing with BH disabled.
>

Yes, this patch did the trick.

Thanks.

Tony



