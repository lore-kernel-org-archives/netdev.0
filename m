From: Daniel Borkmann <dborkman@redhat.com>
Subject: Fwd: [Bug 73891] New: Slow Transfer Speeds though openconnect, Juniper
 SSL vpns
Date: Sat, 12 Apr 2014 20:18:01 +0200
Message-ID: <53498359.8000302@redhat.com>
References: <bug-73891-65011@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, wshuman3@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754795AbaDLSSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2014 14:18:06 -0400
In-Reply-To: <bug-73891-65011@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------- Original Message --------
Subject: [Bug 73891] New: Slow Transfer Speeds though openconnect, Juniper SSL vpns
Date: Sat, 12 Apr 2014 15:35:52 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: dborkman@redhat.com

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
You are watching the assignee of the bug.
