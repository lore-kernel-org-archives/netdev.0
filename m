From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: tc filter flow hash question
Date: Tue, 30 Jun 2009 12:12:54 +0400
Message-ID: <4A49C906.9010102@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:36724 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbZF3IMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 04:12:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 5D27EA6C3B1
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 12:12:51 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jCtUo5TZRpxw for <netdev@vger.kernel.org>;
	Tue, 30 Jun 2009 12:12:50 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTPA id 6F208A6C16C
	for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 12:12:50 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.
Sorry for mail to this maillist, but in internet i can't found any
information to understand this situation, lartc list is dead, function
do not documented and only developers understand how it works.

As i understand if i add flow hash i divide speed to KEYs (example to
dst) not for sessions right?

Why if i add simple example my traffic stop and i get DROP at parent class?

This my sample

tc qdisc add dev eth0 root handle 1 htb default 7
class add dev eth0 parent 1: classid 1:7 htb rate 500mbit ceil 1000mbit
prio 3
qdisc add dev eth0 parent 1:7 handle 10: sfq perturb 10
# all normal
tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys
src,dst
# all traffic drop

Thanks!
Best regals, Badalian Vyacheslav
