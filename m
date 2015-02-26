From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 93901] New: TCP Fast Open uses
Date: Thu, 26 Feb 2015 08:07:29 -0800
Message-ID: <20150226080729.4c567be9@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:42298 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbbBZQH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:07:27 -0500
Received: by mail-oi0-f54.google.com with SMTP id v63so10076843oia.13
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 08:07:27 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id w3sm21646igz.4.2015.02.26.08.07.26
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 08:07:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 26 Feb 2015 15:43:45 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 93901] New: TCP Fast Open uses


https://bugzilla.kernel.org/show_bug.cgi?id=93901

            Bug ID: 93901
           Summary: TCP Fast Open uses
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0-rc1
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: low
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: rueth@comsys.rwth-aachen.de
        Regression: No

TCP Fast Open still uses the TCP Experimental Option even though RFC7413
advises not to use the experimental options field anymore but rather use IANA
assigned option number 34 (https://tools.ietf.org/html/rfc7413#section-9).

-- 
You are receiving this mail because:
You are the assignee for the bug.
