From: "Frank Schneider" <twodipu@hotmail.com>
Subject: approx.  bridging time
Date: Mon, 18 Sep 2006 11:32:09 +0200
Message-ID: <BAY101-F23DBDFCD6F0FDDD104515CAB2D0@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1331747220=="
Cc: netdev@vger.kernel.org
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
To: madwifi-devel@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=madwifi-devel>
List-Post: <mailto:madwifi-devel@lists.sourceforge.net>
List-Help: <mailto:madwifi-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: madwifi-devel-bounces@lists.sourceforge.net
Errors-To: madwifi-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============1331747220==
Content-Type: text/plain; format=flowed

hi,

I am using madwifi.org    as AP mode in Linux kernel 2.6.12 (debian). 
Initially I got a problem to make bridge two interfaces (Ethernet , pcmcia) 
to enable routing inside linux kernel,  then after getting a clue from an 
expert, to use Shorewall.net,  bridging is working perfectly.

Simple setup:  IP packet destined to a STA (station) associated with this AP 
and this packet comes Ethernet interface and then is being routed inside 
linux kernel then using madwifi packets getting into the air.

Now thing is: I am getting these IP packets with some almost “constant 
delay”. It seems packets need some time to be routed inside linux box, to 
jump from Ethernet to pcmcia (madwifi, AP) interface.

Can anyone, please, just give us an idea (approximately) how much time it 
may take to be routed inside linux box (with p4, 512MB), from one Ethernet 
to pcmcia interface ??  (imagine that machine is not doing any other stuff )


/frank

N.B. a good reading, Vincent Guffens, "Path of a packet in the Linux kernel"
http://www.inma.ucl.ac.be/~guffens/doc/path_packet.pdf

_________________________________________________________________
FREE pop-up blocking with the new MSN Toolbar - get it now! 
http://toolbar.msn.click-url.com/go/onm00200415ave/direct/01/



--===============1331747220==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1331747220==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Madwifi-devel mailing list
Madwifi-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/madwifi-devel

--===============1331747220==--
