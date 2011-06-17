From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: what's causing "ip_rt_bug"?
Date: Fri, 17 Jun 2011 22:00:48 +0200
Message-ID: <4DFBB270.8000003@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.virtall.com ([178.63.195.102]:40796 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932986Ab1FQUAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 16:00:50 -0400
Received: from mail.virtall.com (localhost [127.0.0.1])
	by mail.virtall.com (Postfix) with ESMTP id 49E1636467D
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 22:00:49 +0200 (CEST)
Received: from [192.168.10.145] (e183095092.adsl.alicedsl.de [85.183.95.92])
	by mail.virtall.com (Postfix) with ESMTPSA id F206436467A
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 22:00:48 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a system pushing around 800 Mbit/s, ~130 kpps.

It uses 2.6.35.12 kernel.


Several times a minute, I can see entries like (a.b.c.d - IP of this system):

Jun 18 02:39:19 KOR-SV22 kernel: [37187.665951] ip_rt_bug: 110.x.x.x -> a.b.c.d, ?
Jun 18 02:39:19 KOR-SV22 kernel: [37187.685419] ip_rt_bug: 110.x.x.x -> a.b.c.d, ?
Jun 18 02:40:31 KOR-SV22 kernel: [37259.199315] ip_rt_bug: 124.x.x.x -> a.b.c.d, ?
Jun 18 02:40:36 KOR-SV22 kernel: [37263.828000] ip_rt_bug: 124.x.x.x -> a.b.c.d, ?
Jun 18 02:44:16 KOR-SV22 kernel: [37484.120689] ip_rt_bug: 110.x.x.x -> a.b.c.d, ?
Jun 18 02:44:19 KOR-SV22 kernel: [37487.114357] ip_rt_bug: 110.x.x.x -> a.b.c.d, ?

What may be causing this? Is it "dangerous"?


-- 
Tomasz Chmielewski
http://wpkg.org
