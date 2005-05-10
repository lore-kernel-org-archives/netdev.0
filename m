From: Michael Iatrou <m.iatrou@freemail.gr>
Subject: IPsec performance over UDP
Date: Tue, 10 May 2005 19:49:12 +0300
Message-ID: <200505101949.12236.m.iatrou@freemail.gr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I did some testing for IPsec performance over UDP. I used two identical PCs, 
connected back-to-back, with Intel Xeon 2.8GHz (SMP/SMT disabled), 512MB RAM, 
e1000 (82546EB), running Linux 2.6.11.7.  

I tested AES {128,192,256}, DES, 3DES, SHA, MD5 and various combinations of 
them for ESP and AH.

Network performance:
http://members.hellug.gr/iatrou/udp-throughput.png

CPU utilization:
http://members.hellug.gr/iatrou/udp-cpu.png

The "unexpected" result is that there is 30% idle time even if the network is 
not saturated! On the other hand, TCP seems to behave more normally:

Network performance:
http://members.hellug.gr/iatrou/tcp-throughput.png

CPU utilization:
http://members.hellug.gr/iatrou/tcp-cpu.png

Any ideas?

All tests are 100% reproducible.

Additional infos:
MTU 1500
IPsec mode: transport, using preshared keys
netperf 2.3pl1
CPU utilization from /proc/stat

-- 
 Michael Iatrou
 Electrical and Computer Engineering Dept.
 University of Patras, Greece
