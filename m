From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 68821] New: splittcp with tproxy has issues when timestamp
 is enabled
Date: Thu, 16 Jan 2014 09:34:54 -0800
Message-ID: <20140116093454.3880cb4c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:46919 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaAPRe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 12:34:59 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so2865852pde.14
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 09:34:59 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id sy10sm21701415pac.15.2014.01.16.09.34.58
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 09:34:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 16 Jan 2014 05:39:52 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 68821] New: splittcp with tproxy has issues when timestamp is enabled


https://bugzilla.kernel.org/show_bug.cgi?id=68821

            Bug ID: 68821
           Summary: splittcp with tproxy has issues when timestamp is
                    enabled
           Product: Networking
           Version: 2.5
    Kernel Version: 3.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: shailendra7479@gmail.com
        Regression: No

Hi,

I am having an application which does splittcp with transparency. I have a NAT
box which reuses the 5-tuple frequently. Due to this there is a possibility
that some connections with the same tuple go through our splittcp and some may
go directly to the webserver.
Due to this, the webserver is getting confused and not responding with
SYN-ACKs.
Is there a way to enable transparency in TIMESTAMPs when tproxy is involved for
eg., preserve the incoming timestamp in the outgoing SYN.
Shouldn't the kernel be using the client's timestamp in the outgoing SYNs when
transparency is enabled?

Thanks
Shailendra

-- 
You are receiving this mail because:
You are the assignee for the bug.
