From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops with ipcomp
Date: Sat, 2 Feb 2008 15:42:54 +1100
Message-ID: <20080202044254.GA27792@gondor.apana.org.au>
References: <3C59DB883F7B0B4D8096010D45ACCD134F209E@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39769 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758384AbYBBEm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 23:42:57 -0500
Content-Disposition: inline
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD134F209E@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2008 at 11:09:22AM +0100, Beschorner Daniel wrote:
> One more issue with 2.6.24, some hours after I reactivated ipcomp with
> Herb's 2 patches.
> The httpd log shows a http request per esp tunnel at oops time.
> Don't know whether it is for network or compression guys, so I started
> posting here.
> 
> Unable to handle kernel paging request at ffffc200000fb000 RIP: 
>  [<ffffffff8031b8f0>] deflate_slow+0x40/0x400

I'm not able to get much information out of this crash dump.  Nor
can I reproduce this bug on my 32-bit machines and I'm currently
away from my 64-bit machines.

How long have you been using IPComp in the past and what was the
last kernel version which was stable with IPComp?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
