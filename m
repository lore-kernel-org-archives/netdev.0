From: Patrick McHardy <kaber@trash.net>
Subject: Re: net 01/06: Add STP demux layer
Date: Thu, 03 Jul 2008 19:51:05 +0200
Message-ID: <486D1189.2060409@trash.net>
References: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>	<20080703170442.6650.31951.sendpatchset@localhost.localdomain> <20080703104008.0bb74b6e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43959 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbYGCRvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 13:51:09 -0400
In-Reply-To: <20080703104008.0bb74b6e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu,  3 Jul 2008 19:04:42 +0200 (MEST)
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> net: Add STP demux layer
>>
>> Add small STP demux layer for demuxing STP PDUs based on MAC address.
>> This is needed to run both GARP and STP in parallel (or even load the
>> modules) since both use LLC_SAP_BSPAN.
>>
>>
> Why not just have LLC handle multiple registrations for same SAP?


I considered that, but it looks like a lot more work without a
clear advantage - nothing else seems to need it.

