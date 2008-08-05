From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH 2/2] Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 11:36:46 +0300
Message-ID: <200808051136.47222.joakim.koskela@hiit.fi>
References: <200808041619.42562.joakim.koskela@hiit.fi> <200808051013.19873.joakim.koskela@hiit.fi> <20080805072249.GA20340@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:55237 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753800AbYHEIeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 04:34:08 -0400
In-Reply-To: <20080805072249.GA20340@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 August 2008 10:22:49 Herbert Xu wrote:
>
> Also could we avoid the IPV4_BEET_PHMAXLEN part if the inner family
> is IPv6?
>
> Cheers,

Sure, thanks. We should probably do the same in ipv4's output as well (only 
add the IPV4_BEET_PHMAXLEN if the inner family != ipv6).

br, j
