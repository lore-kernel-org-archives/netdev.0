From: Richard Alpe <richard.alpe@ericsson.com>
Subject: Re: [PATCH net-next v1 1/2] tipc: move netlink policies to netlink.h
Date: Thu, 7 Jan 2016 11:20:08 +0100
Message-ID: <568E3BD8.8040209@ericsson.com>
References: <1451987777-17421-1-git-send-email-richard.alpe@ericsson.com>
 <20160105.164749.1356932343853770417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:48598 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbcAGKUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 05:20:19 -0500
In-Reply-To: <20160105.164749.1356932343853770417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-01-05 22:47, David Miller wrote:
> From: Richard Alpe <richard.alpe@ericsson.com>
> Date: Tue, 5 Jan 2016 10:56:16 +0100
> 
>> Make the c files less cluttered and enable netlink attributes to be
>> shared between files. This will prove useful in a future patch where a
>> node message will contain a nested network.
>>
>> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
>> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> 
> netlink.h is included by more than one file, which means the tables
> (might) be instantiated multiple times.
I thought about that, but I assumed unreferenced tables would be
optimized away by the compiler (?)
> 
> I'd really recommend not putting such tables in a header file that
> is used in this way.
Alright, I will drop the patch.

Do you have any suggestion on how to handle the case where a policy
(table) is shared between c files, like the net policy in the
subsequent patch? I could perhaps use extern in the c files (which
seems frown upon) or duplicate the policy? :-S

Thanks for the review
Richard
> 
> Thanks.
> 
