From: Ryousei Takano <ryousei@gmail.com>
Subject: HTB accuracy on 10GbE
Date: Mon, 2 Nov 2009 16:22:16 +0900
Message-ID: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:52312 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbZKBHWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 02:22:12 -0500
Received: by vws30 with SMTP id 30so1193353vws.33
        for <netdev@vger.kernel.org>; Sun, 01 Nov 2009 23:22:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen and all,

I have observed a HTB accuracy problem on the Linux kernel 2.6.30 and
the Myri-10G 10 GbE NIC.
HTB can control the transmission rate at Gigabit speed, however it can
not work well at 10 Gigabit speed.

I asked Stephen this problem at Japan Linux Symposium.  He mentioned a
HTB bug related to the timer granularity.
I want to know what is happen, and what should be do for fixing it.

Any comments and suggestions will be welcome.

For more detail, please see the following page:
http://code.google.com/p/pspacer/wiki/HTBon10GbE

Best regards,
Ryousei
