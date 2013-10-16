From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: Correctly clamp MAX forward_delay when enabling
 STP
Date: Wed, 16 Oct 2013 08:56:57 +0800
Message-ID: <20131016005657.GA5394@gondor.apana.org.au>
References: <1381863465-27304-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49913 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933711Ab3JPA5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 20:57:04 -0400
Content-Disposition: inline
In-Reply-To: <1381863465-27304-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 02:57:45PM -0400, Vlad Yasevich wrote:
> Commit be4f154d5ef0ca147ab6bcd38857a774133f5450
> 	bridge: Clamp forward_delay when enabling STP
> had a typo when attempting to clamp maximum forward delay.
> 
> It is possible to set bridge_forward_delay to be higher then
> permitted maximum when STP is off.  When turning STP on, the
> higher then allowed delay has to be clamed down to max value.
> 
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Good catch!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
