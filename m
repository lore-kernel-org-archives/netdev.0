From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Software receive packet steering
Date: Thu, 23 Apr 2009 00:25:24 -0700 (PDT)
Message-ID: <20090423.002524.32556359.davem@davemloft.net>
References: <20090422.022120.211323498.davem@davemloft.net>
	<Pine.LNX.4.64.0904222156300.21763@ask.diku.dk>
	<20090423065830.GN4593@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hawk@diku.dk, therbert@google.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, andi@firstfloor.org, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se, jens.laas@ITS.UU.SE, hawk@comx.dk
To: jens.axboe@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33668
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751607AbZDWHZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 03:25:32 -0400
In-Reply-To: <20090423065830.GN4593@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Axboe <jens.axboe@oracle.com>
Date: Thu, 23 Apr 2009 08:58:30 +0200

> On Wed, Apr 22 2009, Jesper Dangaard Brouer wrote:
>> On Wed, 22 Apr 2009, David Miller wrote:
>>
>>> One thought I keep coming back to is the hack the block layer
>>> is using right now.  It remembers which CPU a block I/O request
>>> comes in on, and it makes sure the completion runs on that
>>> cpu too.
> 
> Hack?! :-)

I meant hack in the most positive sense :)
