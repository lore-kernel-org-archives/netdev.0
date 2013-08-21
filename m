From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60779] New: tcp_fastretrans_alert triggered on tcp_input.c
Date: Wed, 21 Aug 2013 16:44:39 -0700
Message-ID: <20130821164439.4441c107@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:61494 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab3HUXon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 19:44:43 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so1088408pde.23
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 16:44:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 21 Aug 2013 15:55:49 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60779] New: tcp_fastretrans_alert triggered on tcp_input.c


https://bugzilla.kernel.org/show_bug.cgi?id=60779

            Bug ID: 60779
           Summary: tcp_fastretrans_alert triggered on tcp_input.c
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.7
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: otavio.n.cipriani@gmail.com
        Regression: No

Created attachment 107276
  --> https://bugzilla.kernel.org/attachment.cgi?id=107276&action=edit
Call trace

Unfortunately I do not know how to reproduce the bug. Nothing seems to be
affected.

The only parameters I changed were:
net.core.rmem_max = 4194304;
net.core.wmem_max = 1048576.

-- 
You are receiving this mail because:
You are the assignee for the bug.
