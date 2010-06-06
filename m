From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] KVM: add schedule check to napi_enable call
Date: Sun, 6 Jun 2010 19:40:48 +1000
Message-ID: <20100606094048.GA1979@gondor.apana.org.au>
References: <4C07F8FF0200004800097554@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Bruce Rogers <brogers@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:34906 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751140Ab0FFJkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jun 2010 05:40:52 -0400
Content-Disposition: inline
In-Reply-To: <4C07F8FF0200004800097554@sinclair.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bruce Rogers <brogers@novell.com> wrote:
> Please consider this patch for the 2.6.32, 2.6.33, and 2.6.34 stable trees as well as current development trees. (I've only tested on 2.6.32 however)
> 
>    virtio_net: Add schedule check to napi_enable call
>    Under harsh testing conditions, including low memory, the guest would
>    stop receiving packets. With this patch applied we no longer see any
>    problems in the driver while performing these tests for extended periods
>    of time.
> 
>    Make sure napi is scheduled subsequent to each napi_enable.
> 
>    Signed-off-by: Bruce Rogers <brogers@novell.com>
>    Signed-off-by: Olaf Kirch <okir@suse.de>
>    Acked-by: Rusty Russell <rusty@rustcorp.com.au>
>    Cc: stable@kernel.org

Looks good to me.

Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
