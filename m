From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 47021] New: kernel panic with l2tpv3 & mtu > 1500
Date: Tue, 4 Sep 2012 09:07:56 -0700
Message-ID: <20120904090756.71b34feb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55259 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab2IDQIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 12:08:23 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 23FE61410276
	for <netdev@vger.kernel.org>; Tue,  4 Sep 2012 09:08:17 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Qg+STVJKv8sC for <netdev@vger.kernel.org>;
	Tue,  4 Sep 2012 09:08:16 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 311EC141006D
	for <netdev@vger.kernel.org>; Tue,  4 Sep 2012 09:08:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue,  4 Sep 2012 16:06:06 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 47021] New: kernel panic with l2tpv3 & mtu > 1500


https://bugzilla.kernel.org/show_bug.cgi?id=47021

           Summary: kernel panic with l2tpv3 & mtu > 1500
           Product: Networking
           Version: 2.5
    Kernel Version: 3.2.28
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: a1bert@atlas.cz
        Regression: No


first l2tpv3 packet that enters physical device with MTU > 1500 causes kernel
panic

tunel created using:

l2tpv3tun add tunnel tunnel_id 1 peer_tunnel_id 1 encap udp udp_sport 5001
udp_dport 5001 local 192.168.1.1 remote 192.168.1.2

l2tpv3tun add session tunnel_id 1 session_id 1 peer_session_id 1 dev l2tpeth1


reproducible: always

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
