From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Sysctl for ICMPv6 Rate Limitation
Date: Thu, 24 Oct 2002 16:23:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021024.162355.127875447.yoshfuji@linux-ipv6.org>
References: <20021024.145551.130454003.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210240858060.8872-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0210240858060.8872-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0210240858060.8872-100000@netcore.fi> (at Thu, 24 Oct 2002 08:59:16 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> > > Does this rate-limit all ICMPv6 packets or just ICMPv6 error messages (as 
> > > specified in ICMPv6 specifications).
> > > 
> > > If all, I believe the default of rate-limiting everything is unacceptable.
> > 
> > This patch just adds sysctl.  It is my documentation error...
> > is s/ICMPv6 packets/ICMPv6 error packets/ ok?
> > 
> > (I need to do s/100/HZ/, too; This also lives in ICMP(v4)).
> 
> That change fine with me, thanks.

Please apply the following patch on top of the previous 
"Sysctl for ICMPv6 Rate Limitation" patch.  Thanks.

Index: Documentation/networking/ip-sysctl.txt
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/Documentation/networking/ip-sysctl.txt,v
retrieving revision 1.1.1.1.44.1
retrieving revision 1.1.1.1.44.1.2.2
diff -u -r1.1.1.1.44.1 -r1.1.1.1.44.1.2.2
--- Documentation/networking/ip-sysctl.txt	23 Oct 2002 17:50:19 -0000	1.1.1.1.44.1
+++ Documentation/networking/ip-sysctl.txt	24 Oct 2002 07:03:46 -0000	1.1.1.1.44.1.2.2
@@ -316,7 +316,7 @@
 	Limit the maximal rates for sending ICMP packets whose type matches
 	icmp_ratemask (see below) to specific targets.
 	0 to disable any limiting, otherwise the maximal rate in jiffies(1)
-	Default: 100
+	Default: HZ
 
 icmp_ratemask - INTEGER
 	Mask made of ICMP types for which rates are being limited.
@@ -562,9 +562,9 @@
 
 icmp/*:
 ratelimit - INTEGER
-	Limit the maximal rates for sending ICMPv6 packets.
+	Limit the maximal rates for sending ICMPv6 error packets.
 	0 to disable any limiting, otherwise the maximal rate in jiffies(1)
-	Default: 100
+	Default: HZ
 
 IPv6 Update by:
 Pekka Savola <pekkas@netcore.fi>

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
