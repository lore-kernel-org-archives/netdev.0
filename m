From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/5] bridge: per-vlan stats
Date: Fri, 29 Apr 2016 22:19:42 +0200
Message-ID: <5723C1DE.4050109@cumulusnetworks.com>
References: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
 <20160429.153326.652947047579122837.davem@davemloft.net>
 <5723BABD.4080005@cumulusnetworks.com>
 <20160429.161208.1214717753456694357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37158 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbcD2UTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 16:19:46 -0400
Received: by mail-wm0-f54.google.com with SMTP id a17so53696643wme.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 13:19:45 -0700 (PDT)
In-Reply-To: <20160429.161208.1214717753456694357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2016 10:12 PM, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Fri, 29 Apr 2016 21:49:17 +0200
> 
>> Because that is not needed for the per-vlan stats to work, I did to
>> unify the paths and simplify the pvid code but I can easily drop it
>> and revert back to using the direct pvid id.  The only fetch will be
>> the stats per-cpu pointer then. Would that be acceptable ?
> 
> It would be a step in the right direction, for sure.
> 

Okay, just one more thing I forgot to mention - please note that my code swaps
an unconditional smp_rmb() (in br_get_pvid()) for a pointer fetch, I'm not sure
the pointer fetch is slower as it's probably already in the cache if that vlan
is used.

Anyway, I will resubmit without that patch.

Thanks,
 Nik
