From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: can't apply sch_multiq
Date: Tue, 06 Jan 2009 13:57:46 +0300
Message-ID: <4963392A.2000709@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:53128 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbZAFK5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 05:57:50 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 3056CA6C3E7
	for <netdev@vger.kernel.org>; Tue,  6 Jan 2009 13:57:43 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id H6mTOlwrO9Ut for <netdev@vger.kernel.org>;
	Tue,  6 Jan 2009 13:57:41 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id E0213A6C285
	for <netdev@vger.kernel.org>; Tue,  6 Jan 2009 13:57:41 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.
kernel 2.6.28, iproute2 - 2.6.26 (last release)

Look to Documentation/networking/multiqueue.txt we see:
---
The userspace command 'tc,' part of the iproute2 package, is used to
configure
qdiscs.  To add the MULTIQ qdisc to your network device, assuming the device
is called eth0, run the following command:

# tc qdisc add dev eth0 root handle 1: multiq
---

Let's try!
# tc qdisc add dev eth0 root handle 1: multiq
RTNETLINK answers: Invalid argument

Where mistake?

Thanks for answers!

