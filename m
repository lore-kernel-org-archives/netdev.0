From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: dont dereference tcp header on non tcp frames
Date: Thu, 21 Apr 2011 17:20:11 -0700 (PDT)
Message-ID: <20110421.172011.102558889.davem@davemloft.net>
References: <1303284713.3186.13.camel@edumazet-laptop>
	<20110420.014657.232735224.davem@davemloft.net>
	<1303292410.1813.23.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, eilong@broadcom.com, netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36648
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753091Ab1DVAUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 20:20:46 -0400
In-Reply-To: <1303292410.1813.23.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 20 Apr 2011 12:40:10 +0300

> On Wed, 2011-04-20 at 01:46 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 20 Apr 2011 09:31:53 +0200
>> 
>> > [PATCH] bnx2x: dont dereference tcp header on non tcp frames
>> > 
>> > bnx2x_set_pbd_csum() & bnx2x_set_pbd_csum_e2() use 
>> > tcp_hdrlen(skb) even for non TCP frames
>> > 
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> 
>> Broadcom folks please review.
>> 
> 
> Following patch fixes udp checksum offload flow and also addresses
> issues raised by Eric. We are testing it now.
> 
> From: Vladislav Zolotarov <vladz@broadcom.com>
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Can you guys please wrap this up and formally submit this patch?

Please remember to add appropriate tags for Eric, probably both
"Reported-by: " and "Tested-by: ".

Thank you!
