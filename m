From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] IPv6 recursive locking
Date: Sun, 17 Feb 2008 18:43:24 -0800 (PST)
Message-ID: <20080217.184324.109885283.davem@davemloft.net>
References: <20080217141229.GB1677@nereid>
	<47B87D2B.7040400@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Kristof@provost-engineering.be, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754676AbYBRCms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2008 21:42:48 -0500
In-Reply-To: <47B87D2B.7040400@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 17 Feb 2008 19:30:03 +0100

> I think this bug was introduced by the commit:
> 
> 69cc64d8d92bf852f933e90c888dfff083bd4fc9
> "[NDISC]: Fix race in generic address resolution".

Yep and I'll revert this for now.
