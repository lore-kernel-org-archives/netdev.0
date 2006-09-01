From: "Franco" <franco.daje@virgilio.it>
Subject: i not find in the kernel code the code of this command
Date: Fri, 1 Sep 2006 16:18:05 +0200
Message-ID: <003a01c6cdd1$7151c100$0201a8c0@PCFranco>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp2.tin.it ([212.216.176.222]:27857 "EHLO vsmtp2.tin.it")
	by vger.kernel.org with ESMTP id S932067AbWIAOSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 10:18:07 -0400
Received: from PCFranco (87.1.227.172) by vsmtp2.tin.it (7.2.072.1)
        id 44F6D8F8000B2744 for netdev@vger.kernel.org; Fri, 1 Sep 2006 16:18:06 +0200
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!,
I'm not able to subscrive at this list. My server mail don't send the mail 
and consider it a spam mail...
For this, please send eventual response to this mail address 
(franco.daje@virgilio.it)

The problem is this:
I'm searching, in kernel code, the code that implement thi command:

tc filter add dev eth2 parent ffff: protocol ip prio 1 u32 match ip src 
0.0.0.0/0 police rate $1 burst $2 drop flowid :1

I thought that this code was police.c but seem that it isn't
i must implement a proc file in the code and recompiling the kernel.

Thanks

Franco 

