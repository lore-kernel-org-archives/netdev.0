From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: sky2: early oops in pci_vpd_truncate
Date: Fri, 03 Apr 2009 17:10:19 -0700
Message-ID: <1238803819.3893.3.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:8858 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755736AbZDDAKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 20:10:24 -0400
Received: by wf-out-1314.google.com with SMTP id 29so1430181wff.4
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2009 17:10:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I'm seeing an early oops in current Linus -git right after sky2_probe
unfortunately it scrolls away too fast to get it all, but after a
delayed-printk boot it appears to be a NULL dereference in
pci_vpd_truncate.  sysfs also features prominantly in the backtrace..
is this a known issue?

I see there were some sky2 patches this cycle using the vpd functions,
any pointers/patches to try out?

Harvey

