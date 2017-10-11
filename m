From: Ben Greear <greearb@candelatech.com>
Subject: Ethtool question
Date: Wed, 11 Oct 2017 09:51:56 -0700
Message-ID: <492e57b2-ac0a-ff01-2698-e048e97d8e37@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51056 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751691AbdJKQv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 12:51:56 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id 4513A40A5A2
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 09:51:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed today that setting some ethtool settings to the same value
returns an error code.  I would think this should silently return
success instead?  Makes it easier to call it from scripts this way:

[root@lf0313-6477 lanforge]# ethtool -L eth3 combined 1
combined unmodified, ignoring
no channel parameters changed, aborting
current values: tx 0 rx 0 other 1 combined 1
[root@lf0313-6477 lanforge]# echo $?
1

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
