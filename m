From: Daniel Nilsson <gnuffel@gmail.com>
Subject: network stack bypassing with hw queue classification and QOS?
Date: Tue, 19 Apr 2011 21:17:42 +0200
Message-ID: <BANLkTi=jNezGcDJN-P4xNAht-CiknZa3sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42873 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab1DSTRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 15:17:43 -0400
Received: by qwk3 with SMTP id 3so11088qwk.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 12:17:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have hardware that can classify incoming IP-packets L2-L4, and on
the DS field.
This classification allows me to know what outgoing NIC the packets
should end up on, but I still want normal QOS functionality for this
traffic, so I can't push the packets across while staying in the
driver.

Is there any good way of making use of the availability of a
TCAM-alike packet rule classifier while still having the kernel
sort/drop/queue the packets according to various QOS-settings (with no
limitation on what king of policy that can be used for a certain flow)
before they end up in the outgoind NIC? The aim for this application
is to get good packet rate in a system that doesn't have much CPU to
spare.

/Daniel
