From: N N Ashok <nalkunda@cse.msu.edu>
Subject: Keeping track of an interface
Date: Thu, 20 Mar 2003 03:32:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200303200332.22747.nalkunda@cse.msu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
    I have a situation where I want to record which interface (say eth2) was 
used for a packet (say the current packet). Later I want to be able to send 
other packets over the interface which I recorded if it is up and able to 
send packets.
    What would be the best way to keep track of an interface for the above 
scenario? Could we use the "struct net_device" pointer to the interface? If 
we kept track of "struct net_device" pointer, and later that interface 
flapped, the pointer would no longer be valid (I assume so). Then how should 
do we detect that?
   One way I thought was that we keep track of the "oif" (in "struct fib_nh") 
for the particular device. Is it guaranteed that the same device will always 
have the same "oif" even if it flapped? If so, it would be a simple matter to 
record the "oif" number of the device and later send the packets on that 
interface after checking that the interface is up and able to send packets.

   The broader aim is to route packets of a connection over the same 
interface, like routing all packets of the same TCP session over the same 
interface.

Thanks,
Ashok
