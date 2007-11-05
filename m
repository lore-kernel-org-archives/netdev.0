From: "Matthew Faulkner" <matthew.faulkner@gmail.com>
Subject: localhost network processing on smp machines
Date: Mon, 5 Nov 2007 20:48:39 +0000
Message-ID: <c565abbb0711051248g76fbd695w2dbb13f0e014087d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:15427 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbXKEUsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 15:48:40 -0500
Received: by py-out-1112.google.com with SMTP id u77so3293115pyb
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 12:48:39 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm probably being stupid and very confused here. Appologies if it is
a stupid question.

For a particular test I assign a client to core 1 and a server to core
0. My first assumption was all the sending side kernel TCP/IP
processing will be done on core 1 and all the receiving side
processing on core 0. However, having looked at the linux TCP/IP code,
more specifically the loopback device code, when the loopbacks
dev_queue_xmit function gets called it simply passes the skb to the
netif_rx function. Therefore my question is thus, when i assign the
sending / receiving side to different cores is the actual TCP/IP
processing done the assigned sending / receiving cores ? or is TCP/IP
processing done on the sending side only until a certain point? or is
it simply a single core that does all the TCP/IP processing. If it's
the first two and you have any idea, could you point me where in the
kernel the cores the processing swap over.

Thanks for your help
