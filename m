From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ixgbe: Replace LRO with GRO
Date: Sat, 17 Jan 2009 11:36:29 +1100
Message-ID: <20090117003629.GA22370@gondor.apana.org.au>
References: <20090113092625.GA28015@gondor.apana.org.au> <20090113092828.GA28052@gondor.apana.org.au> <20090114084412.GA17393@gondor.apana.org.au> <20090115034619.GA28267@gondor.apana.org.au> <9929d2390901161532j57528215mdb01f38be1bd4c7f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50158 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751560AbZAQAge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 19:36:34 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390901161532j57528215mdb01f38be1bd4c7f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2009 at 03:32:56PM -0800, Jeff Kirsher wrote:
> 
> Adding Emil to provide further testing details...
> 
> We are seeing data corruption with this patch applied.  When we
> disable GRO the data corruption goes away.
> 
> We have this simple ftp test that does put/get and then compares
> md5sum of the file. The file we get back is different then the one we
> sent with GRO enabled.  The file is around 34MB. Note that we don't
> always see the corruption with 30meg file, but it becomes more
> apparent as we increase the size of the file.
> 
> If this helps - Emil did a diff off of a hexdump output between the
> sent and received file. Looks like the receive was cut off at the end:

Thanks for the info Jeff!

As the file isn't too big, could you do two packet dumps, one
at the sender and one at the receiver? Capturing just the headers
should be sufficient for now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
