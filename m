From: Dan Smith <danms@us.ibm.com>
Subject: C/R: Checkpoint and restore network namespaces and devices
Date: Thu, 25 Feb 2010 12:43:09 -0800
Message-ID: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
Cc: benjamin.thery@bull.net, den@openvz.org, ebiederm@xmission.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:38761 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933660Ab0BYUp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 15:45:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds checkpoint/restart support for network namespaces,
as well as the network devices within.  Currently supports veth, macvlan,
and loopback device types.

Includes the latest feedback and the new macvlan bits.  Rebased on Oren's
official v19.  Changes detailed per patch.

