From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 57071] New: icmp redirects are being ignored
Date: Wed, 24 Apr 2013 08:31:14 -0700
Message-ID: <20130424083114.7b4a4c85@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:39895 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756333Ab3DXPbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 11:31:24 -0400
Received: by mail-pa0-f45.google.com with SMTP id lf10so1262499pab.32
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 08:31:23 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id dg5sm3444775pbc.29.2013.04.24.08.31.22
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 24 Apr 2013 08:31:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 24 Apr 2013 02:59:23 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 57071] New: icmp redirects are being ignored


https://bugzilla.kernel.org/show_bug.cgi?id=57071

           Summary: icmp redirects are being ignored
           Product: Networking
           Version: 2.5
    Kernel Version: 3.7.1
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: per@computer.org
        Regression: No


We operate a transparent web-cache which uses ICMP redirects to divert clients
to the cache.  With kernel 3.7.1 (witnessed in installation systems for
openSUSE 12.3 and Ubuntu 13.04), ICMP redirects appear to be ignored. Same
behaviour seen in 3.8.6.

See also https://bugzilla.novell.com/show_bug.cgi?id=814510

Please let me know which kind of diagnostics you require.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
