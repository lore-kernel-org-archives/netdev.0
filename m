From: Alessandro Selli <dhatarattha@route-add.net>
Subject: Vanilla kernel >=2.4.28-rc2 incompatibility with ADSL modem Dlink
 DSL-G300+
Date: Sun, 06 Mar 2005 17:58:38 +0100
Message-ID: <422B36BE.90809@route-add.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@oss.sgi.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Hello,
I found a problem having to to with the plain vanilla 2.4.28-rc2 and 
2.4.29 kernels when I try to use a Dlink DSL-300G+ ethernet ADSL modem 
on a SS5 machine.

The domain "route-add.net" is running on a Sun SparcStation 5 machine, 
equipped with a Micro-SPARCII, 85 MHz processor. This machine has beeing 
running the domain (web, smtp, ssh, imap, telnet, gopher, finger, 
auth/ident, dns) for a year. The machine has two "le" (10 base T) 
ethernet ports, one is connected to the ADSL modem, the other to the LAN.
The OS is Debian stable (Woody, 3.0).
The kernel is a plain vanilla one, downloaded from 
ftp.it.kernel.org/pub/linux/kernel/v2.4 with no patches applied to it.

The problem showed up after updating to kernel 2.4.28: the ADSL 
connection would never outlive the fifteenth minute.  Even though the 
modem still sensed the ADSL carrier and could be reached into its 
web-based internal control panel over the same ethernet connection that 
served the data exchanged with the ISP, after fifteen minutes it could 
first reach the ISP gateway the connection failed and no packets could 
be neither sent nor received with any host outside the LAN.  The 
connection would be available again after a period varying from a few 
minutes to several hours, three quarters of an hour on the average.
A script that was let running from Jannuary 18th to February 3rd (data 
from Jannuary 29th was lost) produced the following data:

http://route-add.net/ping-noping.txt ("riuscito" = success, "fallito" = 
failed)
http://route-add.net/ping-noping_18012005-28012005.txt
http://route-add.net/ping-noping_07012005-17012005.txt ("persa" = lost 
[connection], "tornata" = [coonection is] back)

I tried changing the wiring, I swapped the ethernet ports the LAN and 
ADSL modem where connected to, I swapped the modem with an identical one 
from a colleague of mine, I upgraded to kernel 2.4.29 all to no avail.
   I then tried the 2.4.28-rc{1,2,3} kernels, and I found the 2.4.28-rc1 
not to exhibit the problem, that manifests itself on the 2.4.28-rc{2,3} 
kernels.
   The problem is sparc-specific, a PC with the very same configuration 
(Debian stable, plain vanilla kernels etc.) did not suffer any 
connection drops.

-- 
Alessandro Selli
Tel: 340.839.73.05
http://alessandro.route-add.net
