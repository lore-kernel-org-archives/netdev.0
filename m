From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 73891] New: Slow Transfer Speeds though openconnect,
 Juniper SSL vpns
Date: Mon, 14 Apr 2014 08:18:24 -0700
Message-ID: <20140414081824.39014bf5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:55053 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbaDNPS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 11:18:27 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so8326195pad.14
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 08:18:27 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id q10sm34418265pbl.29.2014.04.14.08.18.26
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 08:18:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 12 Apr 2014 08:35:59 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 73891] New: Slow Transfer Speeds though openconnect, Juniper SSL vpns


https://bugzilla.kernel.org/show_bug.cgi?id=73891

            Bug ID: 73891
           Summary: Slow Transfer Speeds though openconnect, Juniper SSL
                    vpns
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: wshuman3@gmail.com
        Regression: No

There was a regression in 3.14 which caused slow transfer speeds noticed when
connected to openconnect and juniper ssl vpns.

There was also a discussion about this on the mailing list 
https://lkml.org/lkml/2014/4/2/317

I had time to bisect.
# first bad commit: [53d6471cef17262d3ad1c7ce8982a234244f68ec] net: Account for
all vlan headers in skb_mac_gso_segment

-- 
You are receiving this mail because:
You are the assignee for the bug.
