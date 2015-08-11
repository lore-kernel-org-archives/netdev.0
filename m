From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: option driver crashes on modem removal
Date: Tue, 11 Aug 2015 11:32:20 +0200
Message-ID: <CAGm1_kuUD8j6UTz2of_VHBZJQdT2v-nyPtZq1tm4Sgm1UnYgSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	Dan Williams <dcbw@redhat.com>,
	=?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:36667 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965027AbbHKJju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 05:39:50 -0400
Received: by vkbf67 with SMTP id f67so11155799vkb.3
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 02:39:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have following problem. When removing USB dongle 07d1:3e01 or
SierraWireless MC7304 I get following messages:

option1 ttyUSB10: option_instat_callback: error -71
option1 ttyUSB9: option_instat_callback: error -71
option1 ttyUSB10: option_instat_callback: error -71
option1 ttyUSB9: option_instat_callback: error -71
option1 ttyUSB10: option_instat_callback: error -71
option1 ttyUSB9: option_instat_callback: error -71
INFO: rcu_sched detected stalls on CPUs/tasks: {} (detected by 0,
t=2102 jiffies, g=694, c=693, q=24)
INFO: Stall ended before state dump start
option1 ttyUSB10: option_instat_callback: error -71

drivers/usb/serial/option.c seems to make nothing with such a status
and just prints error. How one would handle this properly and just
unregister device? Do you need more info?

Tested kernels: 3.18.20 and 4.2.0-rc5 (this kernel shows only RCU stall crash)
Hardware: TI am335x

Regards,
Yegor
