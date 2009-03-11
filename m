From: David Miller <davem@davemloft.net>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 06:30:58 -0700 (PDT)
Message-ID: <20090311.063058.236235660.davem@davemloft.net>
References: <20090309200505.GA58375@bts.sk>
	<20090309.170927.130334650.davem@davemloft.net>
	<87bps8fkaw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: md@bts.sk, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50951
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752344AbZCKNbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 09:31:12 -0400
In-Reply-To: <87bps8fkaw.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 11 Mar 2009 11:03:35 +0100

> Perhaps this points to the default buffer sizing heuristics to 
> be too aggressive for >= 1GB?

It's necessary Andi, you can't fill a connection on a trans-
continental connection without at least a 4MB receive buffer.

Did you read the commit message of the change that increased
the limit?
