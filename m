From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: systemport: Fix software statistics for SYSTEMPORT
 Lite
Date: Tue, 8 Aug 2017 14:44:40 -0700
Message-ID: <f7f79e92-952d-59c6-a0f5-0d9f961a2d8f@gmail.com>
References: <20170808213925.26126-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:38256 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752464AbdHHVon (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 17:44:43 -0400
Received: by mail-qt0-f194.google.com with SMTP id p3so4247699qtg.5
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 14:44:43 -0700 (PDT)
In-Reply-To: <20170808213925.26126-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2017 02:39 PM, Florian Fainelli wrote:
> With SYSTEMPORT Lite we have holes in our statistics layout that make us
> skip over the hardware MIB counters, bcm_sysport_get_stats() was not
> taking that into account, resulting in reporting 0 for all SW-maintained
> statistics, fix this by skipping accordingly.
> 
> Fixes: 44a4524c54af ("net: systemport: Add support for SYSTEMPORT Lite")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

David, please ignore this version, I accidentally sent it with the
debugging left.
-- 
Florian
