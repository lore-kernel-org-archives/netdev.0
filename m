From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: can multi app capture on same NIC?(use packet_mmap)
Date: Tue, 22 Jun 2010 02:40:13 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F24985FE8F8@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og113.obsmtp.com ([64.18.2.179]:38855 "HELO
	exprod7og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759074Ab0FVJlg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 05:41:36 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there

I'd like to know multi-app can work with packet_mmap (or traditional AF_PACKET system call)?
i.e.
app1 & app2 capture on the same NIC

will both of them receive the same packet? 

Or this situation will happen?

1.app1 start to receive a packet#1
2.app1 complete receiving, then set the packet_status->TP_STATUS_KERNEL
3.how about app2 at this time? Will it see packet_status=KERNEL, then packet#1 got lost?

I tried to find the relevant code in af_packet.c, seems it doesn't guarantee multi-app capture on same NIC?
Can someone help to point it out?


Thanks
jon 

