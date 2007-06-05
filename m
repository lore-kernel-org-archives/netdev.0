From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC VLAN 01/10]: Fix off-by-ones in VLAN ID checks
Date: Tue, 05 Jun 2007 20:16:46 +0200
Message-ID: <4665A88E.3040706@trash.net>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain> <20070605143651.23717.20253.sendpatchset@localhost.localdomain> <46658C5F.8050302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34984 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbXFESQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 14:16:52 -0400
In-Reply-To: <46658C5F.8050302@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> [VLAN]: Fix off-by-ones in VLAN ID checks
>>
>> The valid range of VLAN IDs is 0-4095, fix using ID 4095.
>>   
> 
> Per http://standards.ieee.org/getieee802/download/802.1Q-1998.pdf
> page 69
> 
> 0xFFF is reserved for future use, so we should not be using VLANs with
> that VID.


Thanks, I just noticed id 4095 didn't work and assumed it was a bug.
I'm going to drop that patch.
