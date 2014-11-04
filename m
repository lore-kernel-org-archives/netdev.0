From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 87701] New: hard cpu lockup during pppd initialization of
 vpn
Date: Tue, 4 Nov 2014 10:09:10 -0800
Message-ID: <20141104100910.4f6679b8@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:62947 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbaKFRyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 12:54:32 -0500
Received: by mail-pd0-f181.google.com with SMTP id y10so1557557pdj.40
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 09:54:31 -0800 (PST)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id al4sm6527264pbc.19.2014.11.06.09.54.29
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 09:54:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 4 Nov 2014 08:35:39 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 87701] New: hard cpu lockup during pppd initialization of vpn


https://bugzilla.kernel.org/show_bug.cgi?id=87701

            Bug ID: 87701
           Summary: hard cpu lockup during pppd initialization of vpn
           Product: Networking
           Version: 2.5
    Kernel Version: 3.18.0-rc3
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: richcoe2@gmail.com
        Regression: No

I did not experience this issue in 3.16 or before.
I did not try 3.17.

I moved from kernel-3.15 to 3.16, and then to kernel 3.18.
When I start forticlientsslvpn on 3.18, the system locks up hard.  No mouse and
no keyboard. 

forticlient starts pppd to enable a vpn connection.
Since this is laptop, I don't get a kernel traceback, or OOPS message.

I'm enabling kdump to see if I can get a reliable traceback.
I was first on 3.18.0-rc2, and moved to 3.18.0-rc3 today, and still have the
issue.

-- 
You are receiving this mail because:
You are the assignee for the bug.
