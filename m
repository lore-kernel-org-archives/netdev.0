From: Abhijit Karmarkar <abhijitk@veritas.com>
Subject: variation in thruput w/ change in mtu on gige
Date: Mon, 26 Apr 2004 17:36:53 +0530 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.50.0404261700390.241-100000@revati>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

i have observed that using jumbo frames (mtu=9000) decreases the thruput
(i am timing one-way ttcp). trying w/ different mtu's i see 4096 give
me the best numbers:

mtu             thruput
-------------------------------
1500 (default)  ~846Mbps
4096            ~930Mbps <== highest
8192            ~806Mbps
9000            ~806Mbps
15K             ~680Mbps

my setup is:
- 2 nodes connected directly (cross-over cable)
- each node: 2-way, 2.4G Xeon. 4G RAM., running RHEL3 (2.4.21-4.ELsmp)
- intel gige (82543GC), e1000 ver. (5.1.11-k1)
  i think the cards are: 64bit/66Mhz PCI.
- ipv4.tcp_r/wmem and core.r/wmem_max set sufficiently high (512KB)
- using ttcp to xfer ~8GB one-way.

why doesn't my thruput increase with increase in MTU? is it because of
small number of rx/txdescriptors on 82543GC (max=256?) or something
else?

are there any driver parameters that i can tune to get better numbers
with larger MTUs?

thanks,
abhijit
