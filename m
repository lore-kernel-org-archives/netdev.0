From: Ben Greear <greearb@candelatech.com>
Subject: ethtool.h compile warning on c++
Date: Fri, 14 Oct 2016 12:46:38 -0700
Message-ID: <2f8c5516-210e-83a4-669f-9bd9316a845f@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:45234 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbcJNTrB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 15:47:01 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id DD08240A339
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 12:46:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am getting warnings about sign missmatch.

Maybe make SPEED_UNKNOWN be ((__u32)(0xFFFFFFFF)) ?

from ethtool.h:

#define SPEED_UNKNOWN           -1

static inline int ethtool_validate_speed(__u32 speed)
{
         return speed <= INT_MAX || speed == SPEED_UNKNOWN;
}

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
