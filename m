From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Fri, 12 Feb 2010 11:55:52 -0800 (PST)
Message-ID: <20100212.115552.166740353.davem@davemloft.net>
References: <1263546020.2038.7.camel@localhost>
	<20100115.010628.67106329.davem@davemloft.net>
	<F86E8680A7D9D74A99DC6345E35A6929501BA2CA@orsmsx503.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37007
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753062Ab0BLTzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 14:55:37 -0500
In-Reply-To: <F86E8680A7D9D74A99DC6345E35A6929501BA2CA@orsmsx503.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Sat, 16 Jan 2010 02:53:15 -0800

> Either way works though.  I still think the table is the better way
> to go, because of the determinism for any system and NIC
> configuration/layout.  The overhead of configuring the table is
> taken during open(), so it's not in the hotpath at all.

How many minus operations can your cpu perform in the same amount
of time it takes to access memory? :-)
