From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH v2] net: bpf_jit: fix divide by 0 generation
Date: Wed, 18 Jan 2012 09:48:07 -0800
Message-ID: <20120118174807.GA5159@linuxace.com>
References: <20120118022709.GA4167@linuxace.com>
 <1326867428.2606.39.camel@edumazet-laptop>
 <1326871835.2606.40.camel@edumazet-laptop>
 <1326873533.2606.46.camel@edumazet-laptop>
 <20120118155747.GA4991@linuxace.com>
 <1326902511.2316.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326907302.4910.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52629 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab2ARRsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 12:48:11 -0500
Received: by iagf6 with SMTP id f6so6311021iag.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 09:48:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1326907302.4910.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2012 at 06:21:42PM +0100, Eric Dumazet wrote:
> Several problems fixed in this patch :
> 
> 1) Target of the conditional jump in case a divide by 0 is performed
>    by a bpf is wrong.
> 
> 2) Must 'generate' the full function prologue/epilogue at pass=0,
>    or else we can stop too early in pass=1 if the proglen doesnt change.
>    (if the increase of prologue/epilogue equals decrease of all
>     instructions length because some jumps are converted to near jumps)
> 
> 3) Change the wrong length detection at the end of code generation to
>    issue a more explicit message, no need for a full stack trace.
> 
> Reported-by: Phil Oester <kernel@linuxace.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> Please Phil test following fix, thanks !

Looks good in testing so far, thank you!

Phil
