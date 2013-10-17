From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Correctly clamp MAX forward_delay when
 enabling STP
Date: Thu, 17 Oct 2013 16:12:58 -0400 (EDT)
Message-ID: <20131017.161258.343998972337901996.davem@davemloft.net>
References: <1381863465-27304-1-git-send-email-vyasevic@redhat.com>
	<20131016005657.GA5394@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758649Ab3JQUM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:12:59 -0400
In-Reply-To: <20131016005657.GA5394@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 16 Oct 2013 08:56:57 +0800

> On Tue, Oct 15, 2013 at 02:57:45PM -0400, Vlad Yasevich wrote:
>> Commit be4f154d5ef0ca147ab6bcd38857a774133f5450
>> 	bridge: Clamp forward_delay when enabling STP
>> had a typo when attempting to clamp maximum forward delay.
>> 
>> It is possible to set bridge_forward_delay to be higher then
>> permitted maximum when STP is off.  When turning STP on, the
>> higher then allowed delay has to be clamed down to max value.
>> 
>> CC: Herbert Xu <herbert@gondor.apana.org.au>
>> CC: Stephen Hemminger <shemminger@vyatta.com>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> Good catch!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks.
