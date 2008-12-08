From: Raz <raziebe@gmail.com>
Subject: 10G intel cards - streaming for over than 30 minutes
Date: Tue, 9 Dec 2008 00:37:26 +0200
Message-ID: <5d96567b0812081437q604f63beg350093439e184dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:17538 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbYLHWh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 17:37:28 -0500
Received: by an-out-0708.google.com with SMTP id d40so579861and.1
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2008 14:37:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been stressing my two duals 10G  82598EB cards, all 4 ports connected.
At the beginning all was OK , 24Gbps outgoing traffic from all ports (
6 Gbps from each port).
But after some time, aprroximately 30 minutes, one of the ports
started to return QUEUE BUSY errors.

I am using 2.6.18-8.el5 kernel, my motherboard is a Supermicro 1025WR,
64bit, PCI-E2.
Why is that ? Is this a known bug ? should I move to a newer driver ?
Should I disable
or enable DCA in BIOS ?

thank you
raz
