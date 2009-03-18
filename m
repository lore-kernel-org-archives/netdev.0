From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: next-20090318: sunhme does not transmit packets
Date: Wed, 18 Mar 2009 17:34:30 +0300
Message-ID: <a4423d670903180734w7270a4f3qa2af3981b969436c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:23330 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756376AbZCROed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 10:34:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Ultra 10 can boot, it receives DHCP answer, ssh works, but few minutes
after machine becomes unresponsible by net at all.
It does not respond even on ARP requests.

On Sparc host I see that `TX packets` does not grow, but RX grows.
The state of the interface is
UP BROADCAST RUNNING MULTICAST

There is no relevant kernel messages in dmesg.

next-20090317 worked fine.


Let me know if I can help.
