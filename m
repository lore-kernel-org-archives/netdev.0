From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Application brokne due to XFRMA_ALG_AUTH_TRUNC
Date: Tue, 04 Oct 2011 22:35:33 +0100
Message-ID: <1317764133.2751.13.camel@bwh-desktop>
References: <CADsjWXR66C2SdfmLP0wqRvbcDJkXbYBN=zzTZLP5_+pE0fenqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eduardo Panisset <eduardo.panisset@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2074 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932558Ab1JDVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 17:35:36 -0400
In-Reply-To: <CADsjWXR66C2SdfmLP0wqRvbcDJkXbYBN=zzTZLP5_+pE0fenqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-10-04 at 18:08 -0300, Eduardo Panisset wrote:
> Hi All,
> 
> I have an application compiled against kernel 2.6.32 and which is
> using XFRMA_MARK (value 20).

It was not defined in 2.6.32.  Perhaps you are using a distribution that
backported this feature incorrectly?

> However the same aplication does not work anymore on kernel 2.6.38.8
> due to XFRMA_MARK has now the value 21 because of a new attribute
> XFRMA_ALG_AUTH_TRUNC inserted before it in the file linux/xfrm.h.
> Now the only solution would be recompiling this application. Is
> correct introducing a new parameter in the middle of an existing enum
> in the kernel headers ?

So far as I can see, in mainline Linux versions the value has always
been 21.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
