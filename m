From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 79821] New: ethernet/freescale/gianfar_ethtool.c:1584:
 possible bad expression ?
Date: Thu, 10 Jul 2014 05:51:00 -0700
Message-ID: <20140710055100.394e6a09@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46672 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbaGJMvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 08:51:06 -0400
Received: by mail-pa0-f47.google.com with SMTP id kq14so11072518pab.34
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 05:51:04 -0700 (PDT)
Received: from samsung-9 ([2001:67c:618:606:c55f:d77d:5341:d760])
        by mx.google.com with ESMTPSA id dr9sm21451634pdb.78.2014.07.10.05.51.03
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:51:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 10 Jul 2014 04:25:50 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 79821] New: ethernet/freescale/gianfar_ethtool.c:1584: possible bad expression ?


https://bugzilla.kernel.org/show_bug.cgi?id=79821

            Bug ID: 79821
           Summary: ethernet/freescale/gianfar_ethtool.c:1584: possible
                    bad expression ?
           Product: Networking
           Version: 2.5
    Kernel Version: 3.16-rc4
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: dcb314@hotmail.com
        Regression: No

[linux-3.16-rc4/drivers/net/ethernet/freescale/gianfar_ethtool.c:1584]: (style)
Same expression on both sides of '|'.

    for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);

-- 
You are receiving this mail because:
You are the assignee for the bug.
