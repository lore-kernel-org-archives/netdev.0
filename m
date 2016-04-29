From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/5] bridge: per-vlan stats
Date: Fri, 29 Apr 2016 21:49:17 +0200
Message-ID: <5723BABD.4080005@cumulusnetworks.com>
References: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
 <20160429.153326.652947047579122837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38482 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbcD2TtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 15:49:21 -0400
Received: by mail-wm0-f49.google.com with SMTP id g17so52512003wme.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 12:49:20 -0700 (PDT)
In-Reply-To: <20160429.153326.652947047579122837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2016 09:33 PM, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Thu, 28 Apr 2016 17:52:46 +0200
> 
>> This set adds support for bridge per-vlan statistics.
> 
> Between the counter bumps in fast paths and new levels of pointer
> indirection in order to RCU things, I have to agree with Stephen
> that this new overhead is really pushing it.
> 
> All of this new overhead contributes to the transactional overhead
> for every single packet.
> 
> Sorry I'm not going to apply this for now, unless you can come up
> with something significantly cheaper.
> 
> Thanks.
> 

Okay, thanks for the feedback. Is this about the RCUfication of the pvid ?
Because that is not needed for the per-vlan stats to work, I did to unify the paths
and simplify the pvid code but I can easily drop it and revert back to using
the direct pvid id.
The only fetch will be the stats per-cpu pointer then. Would that be acceptable ?

Cheers,
 Nik
