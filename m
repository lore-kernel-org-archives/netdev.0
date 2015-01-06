From: Sunderam K <sunderam_k@yahoo.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Tue, 6 Jan 2015 01:05:21 +0000 (UTC)
Message-ID: <loom.20150106T020250-42@post.gmane.org>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com> <20141112084138.GL6390@secunet.com> <20141115031549.GA19208@gondor.apana.org.au> <20141120072650.GT6390@secunet.com> <20141120074342.GA29544@gondor.apana.org.au> <20141120075943.GU6390@secunet.com> <20141120080205.GA29710@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50345 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754039AbbAFBKS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 20:10:18 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Y8Iep-0004yC-L5
	for netdev@vger.kernel.org; Tue, 06 Jan 2015 02:10:04 +0100
Received: from 207.140.44.228 ([207.140.44.228])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 02:10:03 +0100
Received: from sunderam_k by 207.140.44.228 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 02:10:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert <at> gondor.apana.org.au> writes:

> 
> On Thu, Nov 20, 2014 at 08:59:44AM +0100, Steffen Klassert wrote:
> >
> > Sure, but could be an option if this is really a rare case.
> 
> Well it's rare but when it does hit it'll probably be there all
> the time for that system.  IOW you either have no apps using the
> FPU, but when you do, it's probably going to be hogging it.
> 
> > Anyway, I don't mind too much about the solution as long as we
> > get it to work :)
> 
> :)
> 
> Cheers,


Hi Herbert

Is there an official "blessed" patch for this re-ordering problem?
I saw some issues raised in the thread with the patch that Ming Liu had 
provided? 

Thanks
-sunderam
