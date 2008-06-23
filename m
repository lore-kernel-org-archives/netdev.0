From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: tc regression?
Date: Mon, 23 Jun 2008 17:30:02 +0400
Message-ID: <485FA55A.4070107@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:58912 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbYFWNhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 09:37:47 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 91E90A6C3D1
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 17:30:10 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UAxoisow740l for <netdev@vger.kernel.org>;
	Mon, 23 Jun 2008 17:30:03 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 80251A6C221
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 17:30:02 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.

Ditrib: Gentoo (i hope its not gentoo bug...)

I try update package to "sys-apps/iproute2-2.6.25.20080417" and see that 
filter can't del filter...

# tc filter show dev eth1 | grep 4:29:d1
filter parent 1: protocol ip pref 5 u32 fh 4:29:d1 order 209 key ht 4 
bkt 29 flowid 1:b7aa

# tc filter del dev eth1 parent 1: pref 5 handle 4:29:d1 u32
RTNETLINK answers: Invalid argument
We have an error talking to the kernel

after rollback to package"sys-apps/iproute2-2.6.24.20080108" all deleted 
normal...

kernel 2.4.24

Thanks!

P.S. not any critical for me... only "for intresting" report =)
