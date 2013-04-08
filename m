From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: add R-Car support for real
Date: Mon, 08 Apr 2013 17:34:53 +0400
Message-ID: <5162C77D.4050802@cogentembedded.com>
References: <201303290051.32106.sergei.shtylyov@cogentembedded.com> <20130408023936.GA1643@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, phil.edworthy@renesas.com
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:45437 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935817Ab3DHNf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 09:35:56 -0400
Received: by mail-la0-f47.google.com with SMTP id fj20so5342011lab.20
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 06:35:54 -0700 (PDT)
In-Reply-To: <20130408023936.GA1643@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08-04-2013 6:39, Simon Horman wrote:

>> Commit d0418bb7123f44b23d69ac349eec7daf9103472f (net: sh_eth: Add eth support
>> for R8A7779 device) was a failed attempt to add support for one of members of
>> the R-Car SoC family.  That's for three reasons: it treated R8A7779 the  same
>> as SH7724 except including quite dirty hack adding ECMR_ELB  bit  to the mask
>> in sh_eth_set_rate() while not removing ECMR_RTM bit (despite it's reserved in
>> R-Car Ether), and it didn't add a new register offset array despite the closest
>> SH_ETH_REG_FAST_SH4 mapping differs by 0x200 to the offsets all the R-Car Ether
>> registers have, and also some of the registers in this old mapping don't exist
>> on R-Car Ether (due to this, SH7724's 'sh_eth_my_cpu_data' structure is not
>> adequeate for R-Car too).  Fix all these shortcomings, restoring the SH7724
>> related section to its pristine state...

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> Hi Sergei,

> thanks for this and sorry for not noticing it earlier.
> I will try exercising it on the r8a7790 lager.

> IIRC you previously mentioned that you were doing work on unravelling
> the #define mess in sh_eth. I am wondering if you have made any progress
> in that area.

    Not much -- I was swithced to USB work.

WBR, Sergei
