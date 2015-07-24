From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 99461] recvfrom SYSCALL infinite loop/deadlock chewing
 100% CPU [was __libc_recv (fd=fd@entry=300, buf=buf@entry=0x7f6042880600,
 n=n@entry=5, flags=-1, flags@entry=258) at
 ../sysdeps/unix/sysv/linux/x86_64/recv.c:33]
Date: Fri, 24 Jul 2015 08:47:38 -0700
Message-ID: <20150724084738.47a5f9ac@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36033 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbbGXPr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 11:47:29 -0400
Received: by pachj5 with SMTP id hj5so16211394pac.3
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 08:47:29 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id k5sm15267055pdb.53.2015.07.24.08.47.28
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 08:47:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 24 Jul 2015 11:22:17 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 99461] recvfrom SYSCALL infinite loop/deadlock chewing 100% CPU [was __libc_recv (fd=fd@entry=300, buf=buf@entry=0x7f6042880600, n=n@entry=5, flags=-1, flags@entry=258) at ../sysdeps/unix/sysv/linux/x86_64/recv.c:33]


https://bugzilla.kernel.org/show_bug.cgi?id=99461

--- Comment #4 from Dan Searle <dan@censornet.com> ---
Is there anyone working on a fix for this bug? Is there any way a fix can be
expedited?

-- 
You are receiving this mail because:
You are the assignee for the bug.
