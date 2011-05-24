From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH] be2net: hash key for rss-config cmd not set
Date: Mon, 23 May 2011 22:46:48 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F63CC4DA8EC4@EXMAIL.ad.emulex.com>
References: <249a7eac-6aa7-481d-b7b0-a2a3b144963f@exht1.ad.emulex.com>
 <20110523.155206.345121915872826257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:17362 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751246Ab1EXFrK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 01:47:10 -0400
In-Reply-To: <20110523.155206.345121915872826257.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, May 24, 2011 1:22 AM
> To: Perla, Sathya
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH] be2net: hash key for rss-config cmd not set
> 
> From: Sathya Perla <sathya.perla@emulex.com>
> Date: Mon, 23 May 2011 17:55:27 +0530
> 
> > Need a random hash key to effectively hash incoming connections into
> > multiple RX rings.
> >
> > Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> 
> You're saying you need a random hash key, yet you're assigning
> a constant.
> 
> Why not use a real random number, via get_random() or similar?

I meant to say a non-zero, non-descript value is needed as the hash key. That was the reason I had left the hash variable un-initialized; but on some systems I get a zero value and hashing is not effective. The constant value I tried (not of any significance) seems to work fine.

Pls let me know if you want me to re-send the patch with a more-descriptive changelog...

thanks.
-Sathya
