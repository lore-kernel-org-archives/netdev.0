From: David Miller <davem@davemloft.net>
Subject: Re: [ANN] Unified dynamic storage for different socket types
 instead of separate hash tables.
Date: Thu, 22 Mar 2007 12:03:46 -0700 (PDT)
Message-ID: <20070322.120346.41643926.davem@davemloft.net>
References: <20070322180957.GA17793@2ka.mipt.ru>
	<20070322114304.1e516507@freekitty>
	<20070322185944.GA3802@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36407
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964917AbXCVTDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:03:46 -0400
In-Reply-To: <20070322185944.GA3802@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 22 Mar 2007 21:59:44 +0300

> Yes, current code does not support statistics.
> Existing stats run over whole hash table, I do not like such approach,
> so I will introduce a per-protocol lists of all sockets, which can be
> accessed from statistics code, but it is next step.

We are _NOT_ bloating up the socket structure even more because your
data structure does not support a "iterate over all objects"
operation.

We got rid of the linked list of all sockets per-protocol precisely
for this reason 10 years ago, you cannot add it back, sorry.
