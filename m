From: David Miller <davem@davemloft.net>
Subject: Re: [ANN] Unified dynamic storage for different socket types
 instead of separate hash tables.
Date: Thu, 22 Mar 2007 12:36:04 -0700 (PDT)
Message-ID: <20070322.123604.70210071.davem@davemloft.net>
References: <20070322191449.GA25274@2ka.mipt.ru>
	<20070322.122120.115923509.davem@davemloft.net>
	<20070322193051.GB1181@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934192AbXCVTgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:36:04 -0400
In-Reply-To: <20070322193051.GB1181@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 22 Mar 2007 22:30:52 +0300

> > 2) An extra list insert/delete to give list of all sockets
> 
> That is too small price.

In your imagination.  Our connection rates went up significantly
when I got rid of the linked list we had many years ago.

Every memory access matters.
