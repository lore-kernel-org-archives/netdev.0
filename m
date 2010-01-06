From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 05 Jan 2010 20:40:39 -0800 (PST)
Message-ID: <20100105.204039.186318305.davem@davemloft.net>
References: <7608421F3572AB4292BB2532AE89D5658B0BAE949E@AVEXMB1.qlogic.org>
	<20100105.195156.39644124.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D5658B0B6E5012@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60435
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754858Ab0AFEkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 23:40:35 -0500
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0B6E5012@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Tue, 5 Jan 2010 20:27:24 -0800

> May be some of this can be achieved with GRO + rx interrupt
> coalesce thresholds, etc.

GRO achieves this with NAPI.

Of course, conservative HW interrupt settings help this
even more, and that is what we suggest NAPI drivers do
anyways.
