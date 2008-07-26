From: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
Subject: emp_ematch.y:11: unrecognized: %error-verbose
Date: Fri, 25 Jul 2008 20:32:42 -0800 (AKDT)
Message-ID: <Pine.LNX.4.64.0807252016450.18879@filesrv1.baby-dragons.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns3.system-techniques.com ([204.91.156.41]:45764 "EHLO
	ns3.baby-dragons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbYGZEoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 00:44:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 	Hello All ,  using ./configure ; make ,  bison seems to dislike the 
subject matter .  Any further info just ask .  Insights welcome .
 		Tia ,  JimL

gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLVE_HOSTNAMES -DDESTDIR=\"/usr/\" -DCONFIG_GACT -DCONFIG_GACT_PROB   -c -o m_ematch.o m_ematch.c
bison -d -t -v -o emp_ematch.yacc.c emp_ematch.y
emp_ematch.y:11: unrecognized: %error-verbose
emp_ematch.y:11:    Skipping to next %
make[1]: *** [emp_ematch.yacc.c] Error 1
make[1]: Leaving directory `/home/archive/iproute2-2.6.26/tc'
make: *** [all] Error 2


 	The build environment ...

# bison --version
bison (GNU Bison) 1.35


# sh /usr/src/linux/scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux filesrv1 2.6.18.3 #2 SMP Fri Jan 5 20:01:06 PST 2007 i686 unknown unknown GNU/Linux

Gnu C                  3.3.6
Gnu make               3.80
binutils               2.15.92.0.2
util-linux             2.12p
mount                  2.12p
module-init-tools      3.1
e2fsprogs              1.38
jfsutils               1.1.8
reiserfsprogs          3.6.19
xfsprogs               2.6.13
pcmcia-cs              3.2.8
quota-tools            3.12.
PPP                    2.4.4b1
nfs-utils              1.0.7
Linux C Library        2.3.5
Dynamic linker (ldd)   2.3.5
Linux C++ Library      5.0.7
Procps                 3.2.5
Net-tools              1.60
Kbd                    1.12
Sh-utils               5.2.1
udev                   064
Modules Loaded



-- 
+------------------------------------------------------------------+
| James   W.   Laferriere | System    Techniques | Give me VMS     |
| Network&System Engineer | 2133    McCullam Ave |  Give me Linux  |
| babydr@baby-dragons.com | Fairbanks, AK. 99701 |   only  on  AXP |
+------------------------------------------------------------------+
