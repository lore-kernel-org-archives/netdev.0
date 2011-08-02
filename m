From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: [PATCH] iptables/man: IPv6 TOS mangling fix was backported to
 2.6.35-longterm too
Date: Tue, 02 Aug 2011 10:00:40 +0900
Message-ID: <1312246840.8407.2.camel@nexus.oss.ntt.co.jp>
References: <1307320871-31770-1-git-send-email-pablo@netfilter.org>
	 <1307320871-31770-2-git-send-email-pablo@netfilter.org>
	 <BANLkTikAs7fN2JQJTUwQHAYPPGMf8i9uEA@mail.gmail.com>
	 <alpine.LNX.2.01.1106061618370.17430@frira.zrqbmnf.qr>
	 <1308213411.4062.22.camel@nausicaa>
	 <alpine.LNX.2.01.1106161705300.10015@frira.zrqbmnf.qr>
	 <4DFA1DFC.3000804@trash.net> <1308273097.8612.1.camel@nexus.oss.ntt.co.jp>
	 <1308273246.8612.3.camel@nexus.oss.ntt.co.jp>  <4DFACE41.5010906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DFACE41.5010906@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update man page accordingly.

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp iptables-orig/extensions/libxt_TOS.man iptables/extensions/libxt_TOS.man
--- iptables-orig/extensions/libxt_TOS.man	2011-07-11 17:41:10.000000000 +0900
+++ iptables/extensions/libxt_TOS.man	2011-08-02 09:59:27.356614494 +0900
@@ -28,9 +28,9 @@ Binary XOR the TOS value with \fIbits\fP
 \fIbits\fP\fB/0\fP. See NOTE below.)
 .PP
 NOTE: In Linux kernels up to and including 2.6.38, with the exception of
-longterm releases 2.6.32.42 (or later) and 2.6.33.15 (or later), there is a bug
-whereby IPv6 TOS mangling does not behave as documented and differs from the
-IPv4 version. The TOS mask indicates the bits one wants to zero out, so it needs
-to be inverted before applying it to the original TOS field. However, the
+longterm releases 2.6.32 (>=.42), 2.6.33 (>=.15), and 2.6.35 (>=.14), there is
+a bug whereby IPv6 TOS mangling does not behave as documented and differs from
+the IPv4 version. The TOS mask indicates the bits one wants to zero out, so it
+needs to be inverted before applying it to the original TOS field. However, the
 aformentioned kernels forgo the inversion which breaks --set-tos and its
 mnemonics.


