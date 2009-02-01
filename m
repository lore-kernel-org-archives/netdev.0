From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: gro: Fix handling of imprecisely split packets
Date: Sat, 31 Jan 2009 23:49:49 -0800
Message-ID: <9929d2390901312349p2752f332pdb1ea4e523d184c3@mail.gmail.com>
References: <20090201070117.GA2200@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:7161 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbZBAHtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 02:49:50 -0500
Received: by yw-out-2324.google.com with SMTP id 9so396014ywe.1
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2009 23:49:49 -0800 (PST)
In-Reply-To: <20090201070117.GA2200@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2009 at 11:01 PM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> Hi Jeff:
>
> Please let me know if the ixgbe problems persist with this patch
> against net-next.
>
> gro: Fix handling of imprecisely split packets
>
> The commit 89a1b249edcf9be884e71f92df84d48355c576aa (gro: Avoid
> copying headers of unmerged packets) only worked for packets
> which are either completely linear, completely non-linear, or
> packets which exactly split at the boundary between headers and
> payload.
>
> Anything else would cause bits in the header to go missing if
> the packet is held by GRO.
>
> This may have broken drivers such as ixgbe.
>
> This patch fixes the places that assumed or only worked with
> the above cases.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>

Thanks Herbert!

I have applied the patch and hopefully I will have more information to
you soon.  At the very least, I should have updated information for
you on Monday.

-- 
Cheers,
Jeff
