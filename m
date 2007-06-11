From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC:  Support send-to-self over external interfaces (and veths).
Date: Mon, 11 Jun 2007 18:12:57 +0200
Message-ID: <466D7489.2000004@trash.net>
References: <4669ED81.8060800@candelatech.com> <466D4165.2090506@trash.net> <466D6FD2.1020206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46292 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbXFKQPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 12:15:30 -0400
In-Reply-To: <466D6FD2.1020206@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> I would really prefer to simply make the prio 0 "lookup local"
>> rule deletable so you can rules with higher priority. That
>> allows to do send to self without any further code changes
>> and avoids the need to bind applications to a device.
>>   
> 
> I am not against making that change as well, but it is often easier to
> just bind-to-device
> than to set up specific host routes for every possible combination..as
> it appears your
> method requires.  (I could have mis-understood the routing requirements,
> but it seemed to
> if you wanted any 100 interfaces to send to any other, your method would
> required 100 * 100
> routes.)


If you want arbitary combinations bases solely on routing, yes
(thats not different from not using send to self). But binding
explicitly should also work fine.

