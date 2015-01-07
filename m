From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 90901] New: No traffic when connected to SSL vpn
 (bisected)
Date: Wed, 7 Jan 2015 11:38:14 -0800
Message-ID: <20150107113814.3a845379@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:57842 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055AbbAGTi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:38:27 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so6513662pde.1
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 11:38:26 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id sx4sm2511810pbc.36.2015.01.07.11.38.24
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 11:38:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 7 Jan 2015 09:56:45 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 90901] New: No traffic when connected to SSL vpn (bisected)


https://bugzilla.kernel.org/show_bug.cgi?id=90901

            Bug ID: 90901
           Summary: No traffic when connected to SSL vpn (bisected)
           Product: Networking
           Version: 2.5
    Kernel Version: 3.19rc1 - 3.19rc3
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

When I connect to our Juniper SSL vpn, I can not do anything.  Let me know if
you need anymore information.

e0b46d0ee9c240c7430a47e9b0365674d4a04522 is the first bad commit
commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Nov 7 21:22:23 2014 +0800

    tun: Use iovec iterators

    This patch removes the use of skb_copy_datagram_const_iovec in
    favour of the iovec iterator-based skb_copy_datagram_iter.

-- 
You are receiving this mail because:
You are the assignee for the bug.
