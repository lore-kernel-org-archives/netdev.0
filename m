From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] ip(7) IP_PMTUDISC_PROBE
Date: Tue, 27 Mar 2007 15:52:17 -0400
Message-ID: <460975F1.60901@psc.edu>
References: <11746948063923-git-send-email-jheffner@psc.edu> <11746948061847-git-send-email-jheffner@psc.edu> <11746948063971-git-send-email-jheffner@psc.edu> <p73hcs66a8j.fsf@bingen.suse.de> <4609640D.7010709@psc.edu> <20070327193115.GA28138@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010008000300070002030803"
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>
To: Michael Kerrisk <mtk-manpages@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:53682 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbXC0TwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 15:52:25 -0400
In-Reply-To: <20070327193115.GA28138@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010008000300070002030803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Document new IP_PMTUDISC_PROBE value for IP_MTU_DISCOVERY.  (Going into 
2.6.22).

Thanks,
   -John

--------------010008000300070002030803
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="ip_mtu_probe.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip_mtu_probe.patch"

diff -rU3 man-pages-2.43-a/man7/ip.7 man-pages-2.43-b/man7/ip.7
--- man-pages-2.43-a/man7/ip.7	2006-09-26 09:54:29.000000000 -0400
+++ man-pages-2.43-b/man7/ip.7	2007-03-27 15:46:18.000000000 -0400
@@ -515,6 +515,7 @@
 IP_PMTUDISC_WANT:Use per-route settings.
 IP_PMTUDISC_DONT:Never do Path MTU Discovery.
 IP_PMTUDISC_DO:Always do Path MTU Discovery. 
+IP_PMTUDISC_PROBE:Set DF but ignore Path MTU.
 .TE   
 
 When PMTU discovery is enabled the kernel automatically keeps track of
@@ -550,6 +551,15 @@
 with the
 .B IP_MTU
 option.     
+
+It is possible to implement RFC 4821 MTU probing with
+.B SOCK_DGRAM
+of
+.B SOCK_RAW
+sockets by setting a value of IP_PMTUDISC_PROBE.  This is also particularly
+useful for diagnostic tools such as
+.BR tracepath (8)
+that wish to deliberately send probe packets larger than the observed Path MTU.
 .TP
 .B IP_MTU
 Retrieve the current known path MTU of the current socket. 

--------------010008000300070002030803--
