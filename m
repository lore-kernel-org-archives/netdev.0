From: Dan Smith <danms@us.ibm.com>
Subject: Network device and namespace checkpoint/restart (v3)
Date: Tue, 16 Feb 2010 08:03:02 -0800
Message-ID: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
To: containers@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:60636 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757Ab0BPQFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 11:05:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds checkpoint/restart support for network namespaces,
as well as the network devices within.  Currently supports veth and loopback
device types.

Minor changes this time around, based on feedback from the previous
posting.  Changes are detailed per-patch, and a new one at the end
adds a checkpoint handler for SIT devices (which does the bare minimum
so that we can fail when a device has no support).

