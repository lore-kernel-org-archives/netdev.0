From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 76521] New: no-blocking socket can send data through
 non-existent local port
Date: Wed, 21 May 2014 06:56:05 +0900
Message-ID: <20140521065605.0955afb7@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:54874 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbaETWAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 18:00:12 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so713391pab.5
        for <netdev@vger.kernel.org>; Tue, 20 May 2014 15:00:11 -0700 (PDT)
Received: from samsung-9 ([61.215.197.74])
        by mx.google.com with ESMTPSA id ry10sm95315105pab.38.2014.05.20.15.00.10
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 May 2014 15:00:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 19 May 2014 18:21:19 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 76521] New: no-blocking socket can send data through non-existent local port


https://bugzilla.kernel.org/show_bug.cgi?id=76521

            Bug ID: 76521
           Summary: no-blocking socket can send data through non-existent
                    local port
           Product: Networking
           Version: 2.5
    Kernel Version: 3.11.0-15
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: billhong1998@gmail.com
        Regression: No

Created attachment 136811
  --> https://bugzilla.kernel.org/attachment.cgi?id=136811&action=edit
Run code to reproduce the issue

The attached code is a epoll network client supposed to test a network server
in high traffic case. Multiple threads create non-blocking sockets to simulate
heavy network load. Most sockets work well, but occasionally some sockets can
send data via non-existent local port, and can read data from the port as well.
Maybe I am not acquainted enough with epoll networking programming, and even
not sure if it is a bug in no-blocking i/o or epoll, and also not certain which
websites are the right place to discuss epoll or no-blocking i/o technologies.  

Anyone has any ideas would be greatly appreciated. Thanks.

-- 
You are receiving this mail because:
You are the assignee for the bug.
