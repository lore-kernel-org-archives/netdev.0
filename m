From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Wed, 29 Apr 2009 17:21:31 -0700 (PDT)
Message-ID: <20090429.172131.219368826.davem@davemloft.net>
References: <1240945659.8819.9.camel@Maple>
	<1241050188.18295.13.camel@localhost.localdomain>
	<1241050583.27131.82.camel@merlyn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org, romieu@fr.zoreil.com
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45278
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757151AbZD3AVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:21:37 -0400
In-Reply-To: <1241050583.27131.82.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Wed, 29 Apr 2009 19:16:23 -0500

> On Wed, 2009-04-29 at 17:09 -0700, Don Fry wrote:
>> After going back to my original NAPI changes, email exchanges today
>> with
>> Francois and John, and looking through all the architecture
>> implementation of mmiowb and locking; I agree that this mmiowb is
>> unnecessary since a lock is always released which has all the memory
>> barriers needed.
> 
> [Off-list]

ROFL, actually, on-list :-)
