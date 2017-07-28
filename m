From: Mark Salyzyn <salyzyn@android.com>
Subject: STABLE: net: reduce skb_warn_bad_offload() noise
Date: Fri, 28 Jul 2017 10:29:57 -0700
Message-ID: <4b5d320a-a12e-b27b-cc58-332614684bf2@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: stable@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36743 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbdG1R37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 13:29:59 -0400
Received: by mail-pf0-f175.google.com with SMTP id z129so58789427pfb.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 10:29:59 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please backport the upstream patch to the stable trees (including 
3.10.y, 3.18.y, 4.4.y and 4.9.y):

b2504a5dbef3305ef41988ad270b0e8ec289331c net: reduce 
skb_warn_bad_offload() noise

Impacting performance or creating unnecessary alarm, and will result in 
kernel panic for panic_on_warn configuration.

Sincerely -- Mark Salyzyn
