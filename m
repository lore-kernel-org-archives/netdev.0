From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/8][RFC] qlge: New Qlogic 10Gb Ethernet Driver for 2.6.28
Date: Wed, 10 Sep 2008 13:58:13 -0700
Message-ID: <20080910205813.GA13266@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:29157 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbYIJU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 16:58:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jeff,

The following patches are for further RFC for the Qlogic 10Gb driver.

This series does some more cleanup but mostly consistes of the recieve buffer alignment copy per Dave Miller.

1)  Align inbound ethernet header on 2-byte boundary.
2)  Fix set_ethtool_ops call.
3)  More cleanup per checkpatch.pl.
4)  Version change to v1.00.00-b3

Next additions:
Implement ethtool_op_getlink()
Implement flash


Regards,
Ron Mercer
Qlogic Corporation

