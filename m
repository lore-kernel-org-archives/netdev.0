From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Wed, 31 Mar 2010 22:35:23 -0400
Message-ID: <1270089323.26743.138.camel@bigi>
References: <1270053478.26743.111.camel@bigi>
	 <20100401003352.GA19147@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:18801 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010Ab0DACf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 22:35:28 -0400
Received: by qw-out-2122.google.com with SMTP id 8so255467qwh.37
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 19:35:27 -0700 (PDT)
In-Reply-To: <20100401003352.GA19147@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 08:33 +0800, Herbert Xu wrote:

> If we're going to change this then we should just add a second
> interface field to the selector, rather than trying to overload
> the existing one.

Do you mean to have a selector->iif/oif? Sure that makes sense - but is
a much larger surgery and user space will need to be taught.

Did you look at the patch i sent? i tried to retain current behavior
except for the input check path. output path was working in classifying
with specific netdevs. 

cheers,
jamal

