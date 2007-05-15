From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Tue, 15 May 2007 16:36:12 -0700 (PDT)
Message-ID: <20070515.163612.108807515.davem@davemloft.net>
References: <20070515.143207.80029051.davem@davemloft.net>
	<OF6757F56D.EE5984FD-ON872572DC.0081026C-882572DC.00814B8F@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, krkumar2@in.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rdreier@cisco.com
To: xma@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757128AbXEOXgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 19:36:06 -0400
In-Reply-To: <OF6757F56D.EE5984FD-ON872572DC.0081026C-882572DC.00814B8F@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <xma@us.ibm.com>
Date: Tue, 15 May 2007 16:33:22 -0700

>       That's interesting. So a generic LRO in interface layer will benefit
> the preformance more, right? Receiving path TCP N times is more expensive
> than sending, I think.

If you look at some of the drivers doing LRO, the bulk of the
implementation is in software, so yes :-)
