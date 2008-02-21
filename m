From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates
Date: Wed, 20 Feb 2008 22:15:54 -0800 (PST)
Message-ID: <20080220.221554.128587906.davem@davemloft.net>
References: <OF5F5F5698.07AB615F-ON652573F6.00142D8A-652573F6.00147DC9@in.ibm.com>
	<20080220.214651.235108740.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334026D6511@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752506AbYBUGPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 01:15:17 -0500
In-Reply-To: <8A71B368A89016469F72CD08050AD334026D6511@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Divy Le Ray" <divy@chelsio.com>
Date: Wed, 20 Feb 2008 21:57:08 -0800

> The driver is cxgb3 here, it uses LLTX.

That's extremely unfortunate, hopefully you can update it to
use a model like tg3 and others use.  LLTX is a lost cause
for hardware device drivers, and in fact we'd like to remove
it tree wide eventually.
