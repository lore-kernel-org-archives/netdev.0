From: Daniel Borkmann <dborkman@redhat.com>
Subject: Fwd: [Bug 76781] New: unable to handle NULL in xfrm_input+0x173,
 fatal exception in interrupt
Date: Fri, 23 May 2014 10:42:22 +0200
Message-ID: <537F09EE.5000703@redhat.com>
References: <bug-76781-65011@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, cate@cateee.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178AbaEWImc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 04:42:32 -0400
In-Reply-To: <bug-76781-65011@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-------- Original Message --------
Subject: [Bug 76781] New: unable to handle NULL in xfrm_input+0x173, fatal exception in interrupt
Date: Fri, 23 May 2014 07:07:40 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: dborkman@redhat.com

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
You are watching the assignee of the bug.
