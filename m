From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] cleanup congestion control options
Date: Sat, 14 Jul 2007 06:09:54 +0200
Message-ID: <20070714040953.GE3565@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754685AbXGNEKg@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following cleanups:
- note in the prompt if an option depends on EXPERIMENTAL
- remove "default n"s that didn't have any effect
- remove "default m"s from options under TCP_CONG_ADVANCED:
  if you manually choose congestion control modules you should
  know which ones you want

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/ipv4/Kconfig |   27 ++++++++-------------------
 1 file changed, 8 insertions(+), 19 deletions(-)

--- linux-2.6.22-rc6-mm1/net/ipv4/Kconfig.old	2007-07-13 11:00:22.000000000 +0200
+++ linux-2.6.22-rc6-mm1/net/ipv4/Kconfig	2007-07-13 11:07:34.000000000 +0200
@@ -423,7 +423,6 @@
 
 config TCP_CONG_BIC
 	tristate "Binary Increase Congestion (BIC) control"
-	default m
 	---help---
 	BIC-TCP is a sender-side only change that ensures a linear RTT
 	fairness under large windows while offering both scalability and
@@ -445,7 +444,6 @@
 
 config TCP_CONG_WESTWOOD
 	tristate "TCP Westwood+"
-	default m
 	---help---
 	TCP Westwood+ is a sender-side only modification of the TCP Reno
 	protocol stack that optimizes the performance of TCP congestion
@@ -459,7 +457,6 @@
 
 config TCP_CONG_HTCP
         tristate "H-TCP"
-        default m
 	---help---
 	H-TCP is a send-side only modifications of the TCP Reno
 	protocol stack that optimizes the performance of TCP
@@ -469,9 +466,8 @@
 	other Reno and H-TCP flows.
 
 config TCP_CONG_HSTCP
-	tristate "High Speed TCP"
+	tristate "High Speed TCP (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	default n
 	---help---
 	Sally Floyd's High Speed TCP (RFC 3649) congestion control.
 	A modification to TCP's congestion control mechanism for use
@@ -480,9 +476,8 @@
  	For more detail	see http://www.icir.org/floyd/hstcp.html
 
 config TCP_CONG_HYBLA
-	tristate "TCP-Hybla congestion control algorithm"
+	tristate "TCP-Hybla congestion control algorithm (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	default n
 	---help---
 	TCP-Hybla is a sender-side only change that eliminates penalization of
 	long-RTT, large-bandwidth connections, like when satellite legs are
@@ -490,9 +485,8 @@
 	terrestrial connections.
 
 config TCP_CONG_VEGAS
-	tristate "TCP Vegas"
+	tristate "TCP Vegas (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	default n
 	---help---
 	TCP Vegas is a sender-side only change to TCP that anticipates
 	the onset of congestion by estimating the bandwidth. TCP Vegas
@@ -501,9 +495,8 @@
 	not as aggressive as TCP Reno.
 
 config TCP_CONG_SCALABLE
-	tristate "Scalable TCP"
+	tristate "Scalable TCP (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	default n
 	---help---
 	Scalable TCP is a sender-side only change to TCP which uses a
 	MIMD congestion control algorithm which has some nice scaling
@@ -511,9 +504,8 @@
 	See http://www.deneholme.net/tom/scalable/
 
 config TCP_CONG_LP
-	tristate "TCP Low Priority"
+	tristate "TCP Low Priority (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	default n
 	---help---
 	TCP Low Priority (TCP-LP), a distributed algorithm whose goal is
 	to utilize only the excess network bandwidth as compared to the
@@ -521,9 +513,8 @@
 	See http://www-ece.rice.edu/networks/TCP-LP/
 
 config TCP_CONG_VENO
-	tristate "TCP Veno"
+	tristate "TCP Veno (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	default n
 	---help---
 	TCP Veno is a sender-side only enhancement of TCP to obtain better
 	throughput over wireless networks. TCP Veno makes use of state
@@ -533,10 +524,9 @@
 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
 
 config TCP_CONG_YEAH
-	tristate "YeAH TCP"
+	tristate "YeAH TCP (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 	select TCP_CONG_VEGAS
-	default n
 	---help---
 	YeAH-TCP is a sender-side high-speed enabled TCP congestion control
 	algorithm, which uses a mixed loss/delay approach to compute the
@@ -548,9 +538,8 @@
 	  http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
 
 config TCP_CONG_ILLINOIS
-	tristate "TCP Illinois"
+	tristate "TCP Illinois (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	default n
 	---help---
 	TCP-Illinois is a sender-side modificatio of TCP Reno for
 	high speed long delay links. It uses round-trip-time to
