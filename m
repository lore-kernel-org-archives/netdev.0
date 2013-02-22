From: Alexander Holler <holler@ahsoftware.de>
Subject: Disable IPv4-mapped - enforce IPV6_V6ONLY
Date: Fri, 22 Feb 2013 16:21:26 +0100
Message-ID: <51278CF6.2060402@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:35792 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757033Ab3BVPV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 10:21:59 -0500
Received: from eiche.ahsoftware (p57B20389.dip0.t-ipconnect.de [87.178.3.137])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id 7C94088811E
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 16:21:57 +0100 (CET)
Received: from krabat.ahsoftware (unknown [192.168.207.2])
	by eiche.ahsoftware (Postfix) with ESMTP id 8BEB5403DF
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 15:21:33 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm searching for a way to either enforce IPV6_V6ONLY or to block 
IPv4-mapped addresses on ipv6-sockets (e.g. by using iptables) system-wide.

E.g. net.ipv6.bindv6only doesn't help if something calls

int v6on = 0;
setsockopt(sd, IPPROTO_IPV6, IPV6_V6ONLY, (char *)&v6on, sizeof(v6on))

In such a case I still want to disable or block IPv4-mapped addresses on 
that socket, even if the program thinks it nows it better.

Until now I haven't found a solution.

Regards,

Alexander
