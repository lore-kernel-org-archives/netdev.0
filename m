From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: bonding directly changes underlying device address
Date: Tue, 13 May 2014 14:06:56 +0300
Message-ID: <5371FCD0.7050502@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eyal Perry <eyalpe@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:57523 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760320AbaEMLHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 07:07:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay, Veaceslav

I see  now that alb_set_slave_mac_addr directly changes the underlying 
device mac address without calling dev_set_mac_address when running in 
TLB mode. Is that on purpose? if yes, can you explain why?

I suspect this can lead to funny (or actually sad) bugs in networking 
drivers, can we avoid that?

Or.
