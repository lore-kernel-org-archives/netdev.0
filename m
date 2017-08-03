From: =?UTF-8?Q?Aurimas_Fi=c5=a1eras?= <aurimas@members.fsf.org>
Subject: STABLE: net: cdc_mbim: apply "NDP to end" quirk to HP lt4132
Date: Thu, 3 Aug 2017 21:08:17 +0300
Message-ID: <e255d93c-d74d-e663-0f8c-b8b3a42cc3a5@members.fsf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34057 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751905AbdHCSIV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 14:08:21 -0400
Received: by mail-lf0-f54.google.com with SMTP id g25so9392133lfh.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 11:08:20 -0700 (PDT)
Received: from [192.168.128.209] ([84.240.60.234])
        by smtp.gmail.com with ESMTPSA id l203sm4022751lfb.61.2017.08.03.11.08.17
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 11:08:18 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please backport the upstream patch to the stable trees 4.4.x and 4.9.y:

a68491f895a937778bb25b0795830797239de31f net: cdc_mbim: apply "NDP to 
end" quirk to HP lt4132

Without this patch HP lt4132 LTE/HSPA+ 4G Module (03f0:a31d) is useless.
Ubuntu bug report: 
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1707643

Patch was tested with 4.4.x kernel.

Sincerely
Aurimas Fišeras
