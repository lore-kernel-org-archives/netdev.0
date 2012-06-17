From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues
 default 8 queues
Date: Sun, 17 Jun 2012 11:33:56 +0300
Message-ID: <1339922036.2486.1.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1339688046.20038.3.camel@lb-tlvb-meravs.il.broadcom.com>
 <20120614.133649.794229745961162963.davem@davemloft.net>
 <1339916031.2486.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120617.010817.1214320083280899562.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2747 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754177Ab2FQIeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2012 04:34:10 -0400
In-Reply-To: <20120617.010817.1214320083280899562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-06-17 at 01:08 -0700, David Miller wrote:
> If you're not going to read what I wrote, don't pretend that you did.
> That really irritates me and makes me want to not review or apply your
> patches.
> 
> I didn't say that there wasn't a problem.
> 
> I said that I don't want you to just blaze your own trail without
> getting agreement and coordinating to adjust the other drivers in
> unison as well.  I refuse to allow you to just change the default of
> your driver and then well... maybe other drivers follow and maybe
> others do not.  That hodge-podge inconsistent situation sucks for
> users.
> 
> So now are you going to try again to explain the problem to me or
> are you going to understand what my actual concern is?
> 

I understood what you are saying, and if it looks like I was still
pushing for this patch to be accepted then I apologize, it is not what
I'm trying to do. What I am trying to do now, is to find a way to set a
default for all drivers. Since set_channels is applicable to only two
drivers now, it does not sound like a good path - so I was asking if you
can consider a kernel parameter as acceptable path. To be clear, I'm
asking if adding the default for all multi-queue drivers in the form of
a kernel parameter is a good path to explore.
