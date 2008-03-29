From: Carsten Jacobi <carsten@ccac.rwth-aachen.de>
Subject: [PATCH] lne390 and Jensen Alphas
Date: Sat, 29 Mar 2008 15:48:18 +0100
Message-ID: <209D18A1-2B61-47F8-B1DC-067C1E676B9D@ccac.rwth-aachen.de>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: multipart/mixed; boundary=Apple-Mail-2-861632122
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-05.arcor-online.net ([151.189.21.45]:42344 "EHLO
	mail-in-05.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751822AbYC2OsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 10:48:20 -0400
Received: from mail-in-09-z2.arcor-online.net (mail-in-09-z2.arcor-online.net [151.189.8.21])
	by mail-in-05.arcor-online.net (Postfix) with ESMTP id 4F30F183575
	for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 15:48:19 +0100 (CET)
Received: from mail-in-01.arcor-online.net (mail-in-01.arcor-online.net [151.189.21.41])
	by mail-in-09-z2.arcor-online.net (Postfix) with ESMTP id 368AE28EDD5
	for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 15:48:19 +0100 (CET)
Received: from [192.168.0.5] (dslb-084-057-167-130.pools.arcor-ip.net [84.57.167.130])
	by mail-in-01.arcor-online.net (Postfix) with ESMTP id 0DC8C10476F
	for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 15:48:19 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-2-861632122
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed

Hello,

I am coming back with an old issue (and I mean 10 years). I have a  
patch for the Mylex LNE390 EISA network adapter that will make it  
work on the Alpha Jensen boards.
The patch has already made public in 1998 (http://lkml.org/lkml/ 
1998/8/9/16) and again in 2003 (http://linux.derkeiler.com/Mailing- 
Lists/Kernel/2003-10/2341.html). I am running the adapter ever since  
in my Jensen Alpha and it had been working just fine during the last  
10 years.
Now, since I posted the patch twice to the linux-kernel mailing list  
without having any snippet of the code getting into the official  
kernel source I try it with this mailing list for a change.
The code itself is supposed for the kernel 2.4.x series but should  
apply to 2.6.x as well. Is there something that speaks against  
pushing it up to the git repository?

With kind regards,

Carsten Jacobi

PS.: I have attached the patch once more
--Apple-Mail-2-861632122
Content-Transfer-Encoding: base64
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name=998_lne390.c.diff.bz2
Content-Disposition: attachment;
	filename=998_lne390.c.diff.bz2

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

--Apple-Mail-2-861632122--
