From: Krzysztof Oledzki <ole@ans.pl>
Subject: SKB BUG: Invalid truesize strikes back, probably ipsec related
Date: Tue, 11 Nov 2008 16:22:40 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0811111610020.26561@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-102723347-1226416960=:26561"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:55385 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756368AbYKKPWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 10:22:51 -0500
Received: from bizon.gios.gov.pl (ole@localhost6 [IPv6:::1])
	by bizon.gios.gov.pl (8.14.3/8.14.3) with ESMTP id mABFMegx005236
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 16:22:42 +0100
Received: from localhost (ole@localhost)
	by bizon.gios.gov.pl (8.14.3/8.14.3/Submit) with ESMTP id mABFMe58005232
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 16:22:40 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-102723347-1226416960=:26561
Content-Type: TEXT/PLAIN; format=flowed; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT

Hello,

After upgrading 2.6.24.7 -> 2.6.26.8 I noticed a lot of messages like:

(...)
Nov 11 12:50:25 fw2 kernel: SKB BUG: Invalid truesize (300) len=150, sizeof(sk_buff)=172
Nov 11 13:00:56 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 13:11:18 fw2 kernel: SKB BUG: Invalid truesize (300) len=150, sizeof(sk_buff)=172
Nov 11 13:14:54 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 13:23:07 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 13:38:08 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 13:45:08 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 13:52:14 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 14:21:20 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 14:56:20 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 15:09:09 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 15:10:19 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 15:10:19 fw2 kernel: SKB BUG: Invalid truesize (300) len=166, sizeof(sk_buff)=172
Nov 11 15:10:19 fw2 kernel: SKB BUG: Invalid truesize (300) len=166, sizeof(sk_buff)=172
Nov 11 15:19:35 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172
Nov 11 15:20:47 fw2 kernel: SKB BUG: Invalid truesize (300) len=150, sizeof(sk_buff)=172
Nov 11 15:24:23 fw2 kernel: SKB BUG: Invalid truesize (300) len=166, sizeof(sk_buff)=172
Nov 11 15:38:19 fw2 kernel: SKB BUG: Invalid truesize (300) len=134, sizeof(sk_buff)=172

It seems that it is the same problem already reported in 
http://bugzilla.kernel.org/show_bug.cgi?id=10996

Is anyone working on it? I'm willing to make required tests or to check 
debug-patches if it may help.

Best regards,

 		Krzysztof Olêdzki
---1144830174-102723347-1226416960=:26561--
