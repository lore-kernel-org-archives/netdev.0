From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 8/9]: sch_hfsc: Use ->requeue queue instead of ops.
Date: Tue, 19 Aug 2008 15:07:10 +0200
Message-ID: <48AAC57E.1090504@trash.net>
References: <20080818.013715.51438108.davem@davemloft.net>	<48A9832D.7030402@trash.net> <20080818.222917.10471071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55141 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbYHSNHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 09:07:14 -0400
In-Reply-To: <20080818.222917.10471071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 18 Aug 2008 16:11:57 +0200
> 
>> I think we really need either ->requeue or a real ->peek operation.
> 
> All the code duplication and complexity is what I'm trying to avoid.
> 
> I see no value in overhauling and auditing all of these ->requeue()
> implementations and how they return status codes when the facility
> itself is largely superfluous.
> 
> Maybe we can simply add a "bool peek" argument or some flags to
> ->dequeue() instead.

Yes, that should work. It might get a big ugly though since the
->dequeue functions have to make sure not to modify any state
while peeking.

