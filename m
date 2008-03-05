From: David Miller <davem@davemloft.net>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Wed, 05 Mar 2008 13:21:12 -0800 (PST)
Message-ID: <20080305.132112.01598419.davem@davemloft.net>
References: <20080305205116.5989A412541@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39048
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756580AbYCEVVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 16:21:12 -0500
In-Reply-To: <20080305205116.5989A412541@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: therbert@google.com (Tom Herbert)
Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)

> This patch implements kernel changes to allow scheduling of softirq's between processors.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

I've stated this in the past and I still feel that it is foolish to
put all of this code into the kernel when every single piece of
networking hardware will be doing this for us transparently.

Maybe if someone had proposed this 4 or 5 years ago, but right now
this code will be irrelevant by the time it ships to any real users.
