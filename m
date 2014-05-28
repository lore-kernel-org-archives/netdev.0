From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 76781] New: unable to handle NULL in xfrm_input+0x173,
 fatal exception in interrupt
Date: Wed, 28 May 2014 14:01:47 -0700
Message-ID: <20140528140147.7eaa538e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:36403 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337AbaE1VBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 17:01:51 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so11869477pbb.27
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 14:01:50 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id se3sm29869767pbb.80.2014.05.28.14.01.50
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 May 2014 14:01:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 23 May 2014 00:07:48 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 76781] New: unable to handle NULL in xfrm_input+0x173, fatal exception in interrupt


https://bugzilla.kernel.org/show_bug.cgi?id=76781

            Bug ID: 76781
           Summary: unable to handle NULL in xfrm_input+0x173, fatal
                    exception in interrupt
           Product: Networking
           Version: 2.5
    Kernel Version: 3.15.0-rc6
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: cate@cateee.net
        Regression: No

See also the fatal oops in:

http://cateee.net/kernel/IMG_20140522_225238.jpg
http://cateee.net/kernel/IMG_20140523_082629.jpg


It seems it happens "often": twice in last few hours I used the new kernels.
(the first oops was with 3.15.0-rc5-00270-gfba69f0)

I had also usual debian unstable updates, and I just finished to instal aiccu
(a sixxs program for dynamic ip6to4, so I'm not sure it is a recent bug or just
I forced it to appear in very last HEAD.

-- 
You are receiving this mail because:
You are the assignee for the bug.
