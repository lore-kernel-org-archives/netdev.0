From: Mehdi Abaakouk <sileht@sileht.net>
Subject: iproute2: Optional 'name' keywork in ip link is broken
Date: Wed, 27 Aug 2014 08:16:41 +0200
Message-ID: <1a520446614670e394cf5226802fe19d@sileht.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sileht.net ([91.224.149.214]:38454 "EHLO chucky.sileht.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932802AbaH0GWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 02:22:08 -0400
Received: from m.sileht.net (alien.sileht.net [IPv6:2a01:6600:8081:d6ff::80])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client did not present a certificate)
	by chucky.sileht.net (Postfix) with ESMTPSA id 46431BF77C
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:16:41 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I got an issue since iproute2 3.16, this command is not working anymore:

# ip link add bar type veth  peer name foo
Error: argument "bar" is wrong: Unknown device

My current workaround is to use the optional "name" keywork for the 
first veth

# ip link add name bar type veth  peer name foo


This issue was introduced by:

http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=9a02651a87d0fd56e2e7eedd63921a050a42b3ec


Regards,

-- 
Mehdi Abaakouk
mail: sileht@sileht.net
irc: sileht
