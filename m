From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 0/10] enic: updates to version 1.4.1.1
Date: Thu, 24 Jun 2010 13:49:10 -0700
Message-ID: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:17894 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab0FXUtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series implements enic driver updates:

01/10 - Feature Add: Replace LRO with GRO
02/10 - Bug Fix: Change hardware ingress vlan rewrite mode
03/10 - Use a lighter reset operation for enic devices
04/10 - Clean up: Add wrapper routines for firmware devcmd calls
05/10 - Use (netdev|dev|pr)_<level> macro helpers for logging
06/10 - Add new firmware devcmds
07/10 - Use receive queue buffer blocks of 32/64 entries
08/10 - Feature Add: Add loopback capability to enic devices
09/10 - Bug Fix: Handle surprise hardware removals
10/10 - Clean ups

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
