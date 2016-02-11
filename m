From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Re: [PATCH net v4] r8169: Bad implementation of netif_carrier_*
Date: Thu, 11 Feb 2016 12:52:49 +0200
Message-ID: <1455187969.3447.4.camel@marian1000.go.ro>
References: <1455172063-1959-1-git-send-email-asd@marian1000.go.ro>
	 <20160211.033915.51059595679987845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-192.residential.rdsnet.ro ([5.14.227.192]:55457 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbcBKKxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 05:53:03 -0500
In-Reply-To: <20160211.033915.51059595679987845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-11 at 03:39 -0500, David Miller wrote:
> From: Corcodel Marian <asd@marian1000.go.ro>
> Date: Thu, 11 Feb 2016 08:27:43 +0200
> 
> >   On probe stage what carrier to stop and rest two situation
> >   netif_carrier_* is slow and disturbing autonegociation process.
> > 
> > Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> 
> This doesn't tell us at all why your change is valid.  You aren't
> going into the details of what you mean by "disturbing" and why it
> being "slow" is really a problem.
> 
> In general, your patches are of a very low quality.  You give never
> give us enough information to properly evaluate your patch.
> 
> It is unlikely that even one of your patches will be applied by
> me until you fix this fundamental problem with your submissions.

May bee netif_carrier_* is good on slow changes of link good status of
interrupt ,is unable to keep track changes from link good interrupt.
