From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 111771] New: deadlock in ppp/l2tp
Date: Wed, 3 Feb 2016 11:04:31 +1100
Message-ID: <20160203110431.7b878a4f@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34116 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbcBCAwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 19:52:06 -0500
Received: by mail-pa0-f43.google.com with SMTP id uo6so3354766pac.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 16:52:05 -0800 (PST)
Received: from samsung9 ([138.44.251.21])
        by smtp.gmail.com with ESMTPSA id b63sm5298931pfj.25.2016.02.02.16.52.03
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 16:52:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please excuse URL mangling, my bugzilla address appears to route through
stupid corporate firewall.

Begin forwarded message:

Date: Tue, 2 Feb 2016 18:38:41 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 111771] New: deadlock in ppp/l2tp


https://urldefense.proofpoint.com/v2/url?u=https-3A__bugzilla.kernel.org_show-5Fbug.cgi-3Fid-3D111771&d=CwICaQ&c=IL_XqQWOjubgfqINi2jTzg&r=q_lvUiVm1uM6QEw9TPH-6jiV__hsrE6xXUAtATPE9x0&m=QRVzJYt9nD-EOW0XdrPpw2-kYmZu0sg62aaPeiiLI_Q&s=l3HC8fgAgyPVwSgMaX2Hjr8GL3P5j2fL1kDXhEW-v9w&e= 

            Bug ID: 111771
           Summary: deadlock in ppp/l2tp
           Product: Networking
           Version: 2.5
    Kernel Version: 4.3.2
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: sorinm@gmail.com
        Regression: No

Created attachment 202771
  --> https://urldefense.proofpoint.com/v2/url?u=https-3A__bugzilla.kernel.org_attachment.cgi-3Fid-3D202771-26action-3Dedit&d=CwICaQ&c=IL_XqQWOjubgfqINi2jTzg&r=q_lvUiVm1uM6QEw9TPH-6jiV__hsrE6xXUAtATPE9x0&m=QRVzJYt9nD-EOW0XdrPpw2-kYmZu0sg62aaPeiiLI_Q&s=2a_KCXgtoQ6NLxDon6_3flSUMpb7Tjj8WhGPZ09E8Vo&e= 
kernel.log, config, cpuinfo

I'm getting a deadlock and the computer is unresponsive shortly after setting
up a xl2tpd/ipsec vpn connection. The deadlock occurs every time, it is very
reproducible on my computer.

It is the mainline kernel, version 4.3.2.

The processor is given in a copy /proc/cpuinfo that I've attached.

uname:
Linux version 4.3.2 (gcc version 5.3.1 20160121 (Debian 5.3.1-7) ) #5 SMP
PREEMPT Sat Jan 30 00:05:40 CET 2016

ppp is from the debian package of their unstable distribution:
ppp_2.4.7-1+2_amd64

I've attached the kernel config file and the kernel log.

-- 
You are receiving this mail because:
You are the assignee for the bug.
