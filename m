From: auto401300@hushmail.com
Subject: netfilter/iptables stopped logging 2.6.35-rc
Date: Sat, 17 Jul 2010 10:20:36 +0300
Message-ID: <20100717072036.1BBE52804B@smtp.hushmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.hushmail.com ([65.39.178.133]:41576 "EHLO
	smtp11.hushmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab0GQHZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jul 2010 03:25:45 -0400
Received: from smtp11.hushmail.com (localhost.localdomain [127.0.0.1])
	by smtp11.hushmail.com (Postfix) with SMTP id CF99A1CA3D6
	for <netdev@vger.kernel.org>; Sat, 17 Jul 2010 07:20:36 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Has something broken with netfilter/iptables logging in 2.6.35-rc,
or is there something new I should set in .config since .34?


I just verified that if I boot .34 and ping the pc it does logging:

Jul 17 09:42:49 xxxxx kernel: Linux version 2.6.34-ab (root@xxxxx) 
(gcc version 4.4.4 (Debian 4.4.4-1) ) #1 SMP PREEMPT Mon May 17 
09:15
:15 EEST 2010
....
Jul 17 09:44:52 xxxxx kernel: DENY  in: IN=eth0 OUT= MAC=xxxxx 
SRC=xxxxx DST=xxxxx LEN=60 TOS=0x00 PREC=0x00 TTL=127 ID=38945 
PROTO=ICMP TYPE=8 CODE=0 ID=512 SEQ=256


but if I boot .35-rc4 and ping:

Jul 17 09:48:08 xxxxx kernel: Linux version 2.6.35-rc4-aa 
(root@xxxxx) (gcc version 4.4.4 (Debian 4.4.4-6) ) #1 SMP PREEMPT 
Mon Jul 5 15:22:02 EEST 2010
....
nothing from iptables in log


userspace is same, only booted different kernel versions


thanks.

