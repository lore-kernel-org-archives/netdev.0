From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 12:38:33 -0800 (PST)
Message-ID: <20100105.123833.119278401.davem@davemloft.net>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE9402@AVEXMB1.qlogic.org>
	<20100105104556.14927d40@nehalam>
	<7608421F3572AB4292BB2532AE89D5658B0BAE9411@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755779Ab0AEUi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 15:38:29 -0500
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0BAE9411@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Tue, 5 Jan 2010 11:02:00 -0800

>> You should be doing GRO, what about multiple addresses per interface,
>> bridging, routing, ...
> 
> We do GRO too (that helps when old firmware didn't support LRO).

You should only do GRO.
