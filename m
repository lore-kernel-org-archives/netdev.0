From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: sky2 rx error problems...
Date: Tue, 30 May 2006 22:08:12 +0100
Message-ID: <6278d2220605301408g646fc01l49a8713763cdc009@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Netfilter Developer" <netfilter-devel@lists.netfilter.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:9848 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932479AbWE3VIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 17:08:13 -0400
Received: by wr-out-0506.google.com with SMTP id 37so80681wra
        for <netdev@vger.kernel.org>; Tue, 30 May 2006 14:08:12 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To follow on from the previous 'sky2 rx error' problem reported, the
problem doesn't have anything to do with iptables or MTU settings, ie
can be reproduced out the box.

The race is hit after a couple of GBs of data. Initially, I thought
this may have something to do with broken MSI support on my Intel
ICH-7M chipset, but disabling MSI didn't help.

kernel: sky2 lan0: rx error, status 0x977d977d length 0

Is there any debug information I can get to help or such? Voluntary
preemption is enabled, UP, HZ=100 on 2.6.17-rc4 on i686.

Dan
-- 
Daniel J Blueman
