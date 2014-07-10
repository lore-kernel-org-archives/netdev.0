From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 79811] New: ethernet/dec/tulip/tulip_core.c:592: array
 index check in wrong place ?
Date: Thu, 10 Jul 2014 05:50:22 -0700
Message-ID: <20140710055022.652ce61d@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:63723 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbaGJMu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 08:50:28 -0400
Received: by mail-pd0-f170.google.com with SMTP id z10so10843336pdj.1
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 05:50:28 -0700 (PDT)
Received: from samsung-9 ([2001:67c:618:606:c55f:d77d:5341:d760])
        by mx.google.com with ESMTPSA id mw3sm32428936pdb.55.2014.07.10.05.50.26
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:50:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 10 Jul 2014 04:21:24 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 79811] New: ethernet/dec/tulip/tulip_core.c:592: array index check in wrong place ?


https://bugzilla.kernel.org/show_bug.cgi?id=79811

            Bug ID: 79811
           Summary: ethernet/dec/tulip/tulip_core.c:592: array index check
                    in wrong place ?
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

ethernet/dec/tulip/tulip_core.c:592]: (style) Array index 'j' is used before
limits check.

            for (j = 0; buf[j] != 0xee && j < 1600; j++)

Suggest put limit check before index use.

-- 
You are receiving this mail because:
You are the assignee for the bug.
