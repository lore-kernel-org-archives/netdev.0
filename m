From: Adam Okuliar <aokuliar@redhat.com>
Subject: [i40e] regression on TCP stream and TCP maerts, kernel-4.12.0-0.rc2
Date: Tue, 30 May 2017 15:43:53 +0200
Message-ID: <655ed9ab-853e-7497-9ea3-cc8d13f56043@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Otto Sabart <osabart@redhat.com>, jhladky@redhat.com
To: netdev@vger.kernel.org, Adrian Tomasov <atomasov@redhat.com>,
        jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:33173 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdE3Nn4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 09:43:56 -0400
Received: by mail-wr0-f175.google.com with SMTP id v104so889140wrb.0
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 06:43:56 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

we found regression on intel card(XL710) with i40e driver. Regression is 
about ~45%
on TCP_STREAM and TCP_MAERTS test for IPv4 and IPv6. Regression was first
visible in kernel-4.12.0-0.rc1.

More details about results you can see in uploaded images in bugzilla. [0]


[0] https://bugzilla.kernel.org/show_bug.cgi?id=195923


Best regards, / S pozdravom,

Adrián Tomašov
Kernel Performance QE
atomasov@redhat.com
