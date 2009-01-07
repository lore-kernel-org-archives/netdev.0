From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 12378] New: Panic when sending heavy traffic
Date: Wed, 7 Jan 2009 11:42:33 -0800
Message-ID: <20090107114233.20b1c280@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38525 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758054AbZAGTm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 14:42:56 -0500
Received: from extreme (pool-96-225-207-155.ptldor.fios.verizon.net [96.225.207.155])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id n07Jgbxi022308
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 7 Jan 2009 11:42:38 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed,  7 Jan 2009 06:45:32 -0800 (PST)
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 12378] New: Panic when sending heavy traffic


http://bugzilla.kernel.org/show_bug.cgi?id=12378

           Summary: Panic when sending heavy traffic
           Product: Networking
           Version: 2.5
     KernelVersion: 2.6.17.13
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: csevijay@gmail.com


Latest working kernel version: 2.6.17.13 
Earliest failing kernel version:
Distribution:
Hardware Environment:e1000 card Supermicro-PDSBA
pro1000GT
Ram:512mb
Software Environment:
Problem Description: Panic when sending heavy traffic

Steps to reproduce:When i pass heavy traffic after some time the linux box went
to panic. and in the backtrace is shows as 

PID: 2194   TASK: f71e50b0  CPU: 0   COMMAND: "xtremed"
 #0 [f71be8c0] crash_kexec at c012edcc
 #1 [f71be904] do_page_fault at c033d6dc
 #2 [f71be950] error_code (via page_fault) at c0102e7d
    EAX: 00000000  EBX: 00000000  ECX: 000f3f23  EDX: f71e5020  EBP: f71be9b4 
    DS:  007b      ESI: 000f3f23  ES:  007b      EDI: 00000000
    CS:  0060      EIP: c01135cf  ERR: ffffffff  EFLAGS: 00010003 
 #3 [f71be984] scheduler_tick at c01135cf
 #4 [f71be9b8] update_process_times at c011e239
 #5 [f71be9d4] timer_interrupt at c01052fb
 #6 [f71be9e8] handle_IRQ_event at c012fd61
 #7 [f71bea10] __do_IRQ at c012fded
 #8 [f71bea38] do_IRQ at c0104587
 #9 [f71bea40] common_interrupt at c0102e1d
    EAX: 1400020a  EBX: 0f070707  ECX: 00000000  EDX: f3b40180  EBP: f71beca8 
    DS:  007b      ESI: f76e5000  ES:  007b      EDI: f71beb3c
    CS:  0060      EIP: c02e036b  ERR: ffffff00  EFLAGS: 00000287 
#10 [f71bea74] ip_route_input at c02e036b


-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
