From: Udo van den Heuvel <udovdh@xs4all.nl>
Subject: VIA velocity hang: how to find cause?
Date: Fri, 3 Mar 2017 13:56:37 +0100
Message-ID: <f4959412-4faf-abee-69b7-2f416379390a@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pindarots.xs4all.nl ([82.161.210.87]:39500 "EHLO
        pindarots.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751660AbdCCQu2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 11:50:28 -0500
Received: from surfplank2.hierzo (localhost.localdomain [127.0.0.1])
        by pindarots.xs4all.nl (8.15.2/8.14.5) with ESMTPS id v23Cub6Q000801
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO)
        for <netdev@vger.kernel.org>; Fri, 3 Mar 2017 13:56:37 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I noticed at least twice that a VIA velocity interface stops functioning
without reason but is revived after and `ifdown eth0; ifup eth0`.
No errors are shown in dmesg or /var/log/messages w.r.t. the interface.
How to find the root cause?

This is with kernel 4.4.48 and .50.

Kind regards,
Udo
