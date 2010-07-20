From: auto401300@hushmail.com
Subject: Re: netfilter/iptables stopped logging 2.6.35-rc
Date: Tue, 20 Jul 2010 22:22:56 +0300
Message-ID: <20100720192256.EC3661200AA@smtp.hushmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: maciej.rutecki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.hushmail.com ([65.39.178.133]:36517 "EHLO
	smtp11.hushmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758661Ab0GTTXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 15:23:05 -0400
Received: from smtp11.hushmail.com (localhost.localdomain [127.0.0.1])
	by smtp11.hushmail.com (Postfix) with SMTP id 5E3DA1CA35B
	for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 19:23:01 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 20 Jul 2010 15:51:03 +0300 Maciej Rutecki 
<maciej.rutecki@gmail.com> wrote:
>On sobota, 17 lipca 2010 o 09:20:36 auto401300@hushmail.com wrote:
>> Hi!
>> 
>> Has something broken with netfilter/iptables logging in 2.6.35-
>rc,
>> or is there something new I should set in .config since .34?
>> 
>> 
>> I just verified that if I boot .34 and ping the pc it does 
>logging:
>> 
>> Jul 17 09:42:49 xxxxx kernel: Linux version 2.6.34-ab 
>(root@xxxxx)
>> (gcc version 4.4.4 (Debian 4.4.4-1) ) #1 SMP PREEMPT Mon May 17
>> 09:15
>> 
>> :15 EEST 2010
>> 
>> ....
>> Jul 17 09:44:52 xxxxx kernel: DENY  in: IN=eth0 OUT= MAC=xxxxx
>> SRC=xxxxx DST=xxxxx LEN=60 TOS=0x00 PREC=0x00 TTL=127 ID=38945
>> PROTO=ICMP TYPE=8 CODE=0 ID=512 SEQ=256
>> 
>> 
>> but if I boot .35-rc4 and ping:
>> 
>> Jul 17 09:48:08 xxxxx kernel: Linux version 2.6.35-rc4-aa
>> (root@xxxxx) (gcc version 4.4.4 (Debian 4.4.4-6) ) #1 SMP 
>PREEMPT
>> Mon Jul 5 15:22:02 EEST 2010
>> ....
>> nothing from iptables in log
>> 
>> 
>> userspace is same, only booted different kernel versions
>
>I created a Bugzilla entry at 
>https://bugzilla.kernel.org/show_bug.cgi?id=16423
>for your bug report, please add your address to the CC list in 
>there, thanks!
>
>-- 
>Maciej Rutecki
>http://www.maciek.unixy.pl


I just thought that whole initramfs may be also different and tried 
to compile
.34 again to test if it still does iptables logging with current 
toolchain but
just now debian kernel-package is broken due to
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=589700
I will try again when that is fixed

thanks.

