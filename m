From: Andrew Brooks <arb@sat.dundee.ac.uk>
Subject: How to debug a driver which hangs (niu)?
Date: Mon, 12 Aug 2013 16:06:24 +0100
Message-ID: <CAHOfOo0kYpa3OtJ2w5xzdi=V6ccm9PKNJ8Pzj+7avNPmZDr9Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Net-Dev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:37342 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756216Ab3HLPGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 11:06:44 -0400
Received: by mail-qc0-f171.google.com with SMTP id n1so901544qcw.2
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 08:06:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I'm using a network driver (niu) which regularly locks-up after
printing the message "transmit timed out"
(i.e. nothing else can be sent/received over that interface after the event).

Does anyone have any tips for helping me to debug this?
eg. how to find out what is causing the transmit timed out message;
how to find out what state the driver is going into which causes the lock-up;
how to get it out of this state and working again?

I'm a programmer but I'm new to kernel drivers so all tips are most
welcome, thanks!

Andrew
