From: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Subject: problem with noop and pfifo_fast Qdisc switching
Date: Thu, 19 Jan 2012 13:47:33 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C105791FB3639775@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:35225 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751335Ab2ASMrq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 07:47:46 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a situation where one of important message (phonet pipe message) gets dropped because of 'noop' Qdisc.
This situation mostly happens when coming out of sleep and there is a message to send.
What I have observed is this.
In normal case the qdisc used id pfifo_fast. When CPU goes to sleep, it changes the qdisc to noop.
When CPU wakes up (because of a message from lower layers), phonet tries to send a control packet to driver and finds qdisc is still 'noop'. 
Because the concerned message is a control message, this packet drop is creating deadlock situation.

How the switch between pfifo_fast and noop is handled? Is this something solved in 3.0?
We are running a older version of kernel (2.6.35 based).

Thanks,
Hemant
 
