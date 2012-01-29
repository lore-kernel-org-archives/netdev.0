From: Simon Chen <simonchennj@gmail.com>
Subject: increase the number of routing tables
Date: Sat, 28 Jan 2012 21:20:42 -0500
Message-ID: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44635 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279Ab2A2CUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 21:20:43 -0500
Received: by wics10 with SMTP id s10so2494086wic.19
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 18:20:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey folks,

To my limited knowledge, Linux currently supports 256 (255?) routing
tables defined in /etc/iproute2/rt_tables.

Is there a way to increase this number to something much larger? Are
there performance/scalability concerns there? I am trying to have
customized routing table for each IP address (using "ip rule add from
xxx table yyy"). I am not sure exactly how many IPs I'll handle, but
certainly more than 255...

Thanks.
-Simon
