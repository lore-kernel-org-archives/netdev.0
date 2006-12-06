From: "Alexey Zaytsev" <alexey.zaytsev@gmail.com>
Subject: Strange problem with tcpdump.
Date: Wed, 6 Dec 2006 21:34:34 +0300
Message-ID: <f19298770612061034p6d4575c8qa0708681d8e01834@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:3286 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937069AbWLFSef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 13:34:35 -0500
Received: by an-out-0708.google.com with SMTP id b33so6575ana
        for <netdev@vger.kernel.org>; Wed, 06 Dec 2006 10:34:35 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, guys.

I've got a problem. I can see all the incoming packets on an ethernet
interface, but no outgoing  packets, although they are sent to the
network, and successfully recieved by the other side. The platform is
ixp420, with severely nodifyed ethernet driver, the kernel is
2.6.16.20. May I ask, how is this possible at all? As I understand,
the outgoing packets get captured before they reach the driver, so it
can't be the cause. On the other hand, I get all the packets sent over
an other, non-ethernet interface, so I can't blame tcpdump. Any
suggestions, where to start the investigation?
