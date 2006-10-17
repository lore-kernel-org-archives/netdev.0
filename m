From: David Miller <davem@davemloft.net>
Subject: Re: PATCH zero-copy send completion callback
Date: Tue, 17 Oct 2006 14:45:03 -0700 (PDT)
Message-ID: <20061017.144503.91315349.davem@davemloft.net>
References: <200610171101.38690.dada1@cosmosbay.com>
	<020d01c6f1e7$029beb70$0281a8c0@ebpc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62910
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750884AbWJQVo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 17:44:59 -0400
To: eeb@bartonsoftware.com
In-Reply-To: <020d01c6f1e7$029beb70$0281a8c0@ebpc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric Barton" <eeb@bartonsoftware.com>
Date: Tue, 17 Oct 2006 13:23:10 +0100

> > Even if your two pointers addition (16 bytes on x86_64) 
> > doesnt cross a 64bytes 
> > line (I didn't checked), they are going to be set to NULL 
> > each time a skbuff 
> > is allocated , and checked against NULL each time a skbuff is 
> > destroyed.
> 
> Indeed.  Do you think that's significant?

On a machine routing a million packets per second, it
definitely is.  It is the most crucial data structure
for performance in all of the networking.
