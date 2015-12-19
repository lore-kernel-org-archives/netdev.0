From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Migrate all elements from net_device_stats
Date: Sat, 19 Dec 2015 08:21:48 +0200
Message-ID: <1450506108.5019.6.camel@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-231-255.residential.rdsnet.ro ([5.14.231.255]:39276 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754003AbbLSPgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 10:36:21 -0500
Received: from [192.168.0.3] (helo=ubuntu)
	by marian1000.go.ro with esmtp (Exim 4.84)
	(envelope-from <asd@marian1000.go.ro>)
	id 1aADTf-0000WQ-AL
	for netdev@vger.kernel.org; Sat, 19 Dec 2015 11:07:08 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
This is not patch .On net_device structure only 2 elements from old
structure net_device_stats exists rx_dropped and tx_dropped why please
put alls elements from net_device_stats for bee ready for atomic
operations.
/include/linux/netdevice.h
-- 
Corcodel Marian <asd@marian1000.go.ro>
