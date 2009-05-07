From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Wed, 06 May 2009 17:28:01 -0700 (PDT)
Message-ID: <20090506.172801.102105067.davem@davemloft.net>
References: <4A0217F6.7060005@netxen.com>
	<20090506.163142.112368323.davem@davemloft.net>
	<4A022666.4060906@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38537
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751098AbZEGA2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 20:28:06 -0400
In-Reply-To: <4A022666.4060906@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed, 6 May 2009 17:08:06 -0700

> I do see a reason for conserving msix vectors, unless
> they are bringing performance gain.

Then scale the number of RX queues in use by port speed.
