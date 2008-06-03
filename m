From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] IPV4: remove addresses and routes when carrier is
 lost
Date: Wed, 04 Jun 2008 00:32:22 +0200
Message-ID: <4845C676.5080801@trash.net>
References: <20080602165249.52a467dc@extreme> <20080603150524.GA16165@csclub.uwaterloo.ca> <20080603085707.51fdabbb@speedy> <48456B62.8050909@trash.net> <20080603214527.GG16162@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53445 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758470AbYFCWcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 18:32:24 -0400
In-Reply-To: <20080603214527.GG16162@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennart Sorensen wrote:
> On Tue, Jun 03, 2008 at 06:03:46PM +0200, Patrick McHardy wrote:
>> Can't the routing daemon simply ignore routes with a
>> device that has no carrier?
> 
> zebra won't add a route that is already provided by the kernel.  The
> kernel has to remove it's route when the link is down before zebra can
> provide an alternative.

That should be easily fixed, the kernel provides all necessary
information to make this decision in userspace.
