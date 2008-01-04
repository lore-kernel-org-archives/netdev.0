From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: e1000_clean_tx_irq: Detected Tx Unit Hang - it's bug?
Date: Fri, 04 Jan 2008 15:36:03 +0300
Message-ID: <477E2833.70301@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:35899 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbYADMgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 07:36:12 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 180F4A6C143
	for <netdev@vger.kernel.org>; Fri,  4 Jan 2008 15:36:11 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1jgvL9dNgpf8 for <netdev@vger.kernel.org>;
	Fri,  4 Jan 2008 15:36:04 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 32FF6A6C2BE
	for <netdev@vger.kernel.org>; Fri,  4 Jan 2008 15:36:04 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.
Some time in dmesg i see this:

[16121.400422] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[16121.400426]   Tx Queue             <0>
[16121.400427]   TDH                  <28>
[16121.400429]   TDT                  <28>
[16121.400430]   next_to_use          <28>
[16121.400431]   next_to_clean        <7d>
[16121.400433] buffer_info[next_to_clean]
[16121.400434]   time_stamp           <17b949>
[16121.400435]   next_to_watch        <7d>
[16121.400437]   jiffies              <17ba57>
[16121.400438]   next_to_watch.status <1>
[16121.400968] htb: too many events !

Its bug or overload information?
Thanks
