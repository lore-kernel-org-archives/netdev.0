From: Ben Greear <greearb@candelatech.com>
Subject: 'iw events' stops receiving events after a while on 4.9 + hacks
Date: Tue, 16 May 2017 10:12:37 -0700
Message-ID: <d82d191e-8ede-68c6-c9e0-c381dc874d36@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:40660 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750784AbdEPRMj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:12:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been keeping an 'iw events' program running with a perl script gathering its
output and post-processing it.  This has been working for several years on 4.7 and earlier
kernels, but when testing on 4.9 overnight, I notice that 'iw events' is not showing any input.  'strace' shows
that it is waiting on recvmsg.  If I start a second 'iw events' then it will get
wifi events as expected.

Are there any known issues in this area?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
