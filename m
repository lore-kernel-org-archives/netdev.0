From: Mason <slash.tmp@free.fr>
Subject: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Tue, 1 Aug 2017 18:32:21 +0200
Message-ID: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:29076 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751755AbdHAQpD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 12:45:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I need suspend/resume support in the nb8800 driver.
On tango platforms, suspend loses all context (MMIO registers).
To make the task easy, we just close the device on suspend,
and open it again on resume. This requires properly resetting
the HW on resume.

Patch 1 moves all the HW init to nb8800_init()
Patch 2 adds suspend/resume support

Regards.
