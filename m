From: Tommy W <tommy@svearike.sytes.net>
Subject: libiptc linking problem under AMD64
Date: Sat, 10 Jun 2006 04:07:31 +0200
Message-ID: <200606100407.31992.tommy@svearike.sytes.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout1-sn1.fre.skanova.net ([81.228.11.98]:36759 "EHLO
	pne-smtpout1-sn1.fre.skanova.net") by vger.kernel.org with ESMTP
	id S1751466AbWFJCHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 22:07:39 -0400
Received: from svearike.sytes.net (83.251.68.35) by pne-smtpout1-sn1.fre.skanova.net (7.2.072.1)
        id 44892B960004DFA9 for netdev@vger.kernel.org; Sat, 10 Jun 2006 04:07:38 +0200
Received: from laptop.sytes.net (wireless_laptop.sytes.net [192.168.8.4])
	by svearike.sytes.net (8.12.11/8.12.11) with ESMTP id k5A27WB7029689
	for <netdev@vger.kernel.org>; Sat, 10 Jun 2006 04:07:33 +0200
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I'm writing an application that uses libiptc and iptables for various 
monitoring applications.

http://www.freshmeat.net/projects/natstat

and I've come upon a small problem with libiptc on AMD64

It won't link into my program, because of lack of the flag -fPIC during 
compile time.

I edited the Makefile for libiptc and put -fPIC in there, voila, everything 
worked.
So my questions now are:

* is there a reason for not having -fPIC ?
* could you add -fPIC ?

Thanks in advance
/Tommy Wallberrg
