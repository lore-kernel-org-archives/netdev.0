From: Frank Li <lznuaa@gmail.com>
Subject: Lower wake up time when phy enter lower mode
Date: Wed, 7 Nov 2012 10:52:32 +0800
Message-ID: <CAHrpEqSw8N4nN6Wgnu2z3tWS_CrGoPMbFj2wJjmDv2JPLW7cLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:46422 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708Ab2KGCwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 21:52:34 -0500
Received: by mail-ia0-f174.google.com with SMTP id y32so791118iag.19
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2012 18:52:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard:

          Recently, I found out the path delay will increase about
20us suddenly in something when connect two iMX6 board and Ethernet
work on 1G mode.
          The reason is that the PHY enter lower mode automatically
when no package send and receive. It takes some time to recover and
send out package by PHY but MAC think package have sent and sample
time stamper.
          Do you meet such case?  I can workaround it by two method
               1. disable phy lower power feature.
               2. add some dummy package before SYNC package.

Best regards
Frank Li
