From: thomas yang <lampsu@gmail.com>
Subject: [ tc ] RTNETLINK answers: Invalid argument
Date: Tue, 24 Nov 2009 19:12:00 +0800
Message-ID: <f4f837ab0911240312x329043b9y7e4694f046121237@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:54114 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932830AbZKXLLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 06:11:54 -0500
Received: by fxm5 with SMTP id 5so5655242fxm.28
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 03:12:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

# tc filter add dev eth1 parent 1: protocol ip prio 10 u32 match ip
src 192.168.1.0/24 flowid 1:16 action mirred egress mirror dev wlan0
Action 3 device wlan0 ifindex 4
RTNETLINK answers: Invalid argument
We have an error talking to the kernel


# uname -a
Linux localhost.localdomain 2.6.30.8-64.fc11.i586 #1 SMP Fri Sep 25
04:30:19 EDT 2009 i686 i686 i386 GNU/Linux

OS :  Fedora 11
