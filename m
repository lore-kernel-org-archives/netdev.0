From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 00/11] enic: updates
Date: Thu, 03 Sep 2009 20:01:43 -0700
Message-ID: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:37487 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617AbZIDDBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:01:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements updates to the enic netdev driver for
Cisco's 10G Ethernet NIC:

      01 enic: add support for multiple BARs
      02 enic: workaround A0 erratum
      03 enic: bug fix: split TSO fragments larger than 16K into
         multiple descs
      04 enic: use netdev_alloc_skb
      05 enic: bug fix: protect fw call i/f with spinlock
      06 enic: bug fix: included MAC drops in rx_dropped netstat
      07 enic: provision for multiple Rx/Tx queues; prepare for RSS support
      08 enic: bug fix: enable VLAN filtering
      09 enic: changes to driver/firmware interface
      10 enic: bug fix: check for zero port MTU before posting warning
      11 enic: organize device initialization/deinit into separate functions

Please apply.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
