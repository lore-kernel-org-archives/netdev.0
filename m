From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 15907] New: IP_ADD_SOURCE_MEMBERSHIP after
 IP_ADD_MEMBERSHIP join on same multicast-group dont return EINVAL
Date: Wed, 5 May 2010 08:21:38 -0700
Message-ID: <20100505082138.6cb93aa1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41916 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755786Ab0EEPV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 11:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 5 May 2010 09:48:40 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 15907] New: IP_ADD_SOURCE_MEMBERSHIP after IP_ADD_MEMBERSHIP join on same multicast-group dont return EINVAL


https://bugzilla.kernel.org/show_bug.cgi?id=15907

           Summary: IP_ADD_SOURCE_MEMBERSHIP after IP_ADD_MEMBERSHIP join
                    on same multicast-group dont return EINVAL
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.34-rc6
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: mail@fholler.de
        Regression: No


Created an attachment (id=26225)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=26225)
asm+ssm join test program

When an SSM IP_ADD_SOURCE_MEMBERSHIP is done after an ASM IP_ADD_MEMBERSHIP
join on the same group(& same interface) the setsockopt operation should return
EINVAL.

The linux implementation returns successfull



https://www3.tools.ietf.org/html/rfc3678#section-4.1.3

I attached an simple C test program.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
