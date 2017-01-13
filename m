From: Ben Greear <greearb@candelatech.com>
Subject: Commit 1fe8e0... (include more headers in if_tunnel.h) breaks my
 user-space build.
Date: Fri, 13 Jan 2017 11:12:32 -0800
Message-ID: <f1cede01-3fa4-130a-fa2d-7cbdfe3648b3@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: netdev <netdev@vger.kernel.org>, mikko.rapeli@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:53548 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdAMTSY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 14:18:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am including netinet/ip.h, and also linux/if_tunnel.h, and the linux/ip.h conflicts with
netinet/ip.h.

Maybe my build environment is screwed up, but maybe also it would be better to
just let the user include appropriate headers before including if_tunnel.h
and revert this patch?


include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and linux/in6.h

     Fixes userspace compilation errors like:

     error: field ‘iph’ has incomplete type
     error: field ‘prefix’ has incomplete type

     Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
     Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
