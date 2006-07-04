From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6791] New: ports in SA should not be zeroed
 when protocol is specified
Date: Tue, 4 Jul 2006 15:41:42 -0700
Message-ID: <20060704154142.b7eddfe7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: klimes@centrum.cz,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17114 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932305AbWGDWly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 18:41:54 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 4 Jul 2006 06:54:01 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6791] New: ports in SA should not be zeroed when protocol is specified


http://bugzilla.kernel.org/show_bug.cgi?id=6791

           Summary: ports in SA should not be zeroed when protocol is
                    specified
    Kernel Version: 2.6.17 and all previous
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: klimes@centrum.cz


Problem Description:
Security assotiations manipulation is defined by RFC2367 - PFKEY API.

However this specification has some drawbacks and unnecessary limitations.
(Maybe RFC2367 would deserve updating as it is rather old.)

Specifically there is a need for an IPsec SA which supports simultaneously TCP
and UDP. Such behaviour can be required by many applications and is e.g.
neccessary for authenticating in 3G according to 3GPP TS 33.203.
Current implementation of PFkey in linux (af_key.c) nethertheless doesn't
support usage of ports as SA selectors and moreover, if a protocol is specified,
the ports are zeroed.

I have found that a bug on this issue has been reported against solaris and has
been corrected - see bugID 6258318
(http://bugs.opensolaris.org/bugdatabase/view_bug.do?bug_id=6258318)
So, I would appreciate to have similar behaviour in linux as well to be competitive.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
