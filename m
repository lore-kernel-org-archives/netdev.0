From: divy@chelsio.com
Subject: [PATCH 0/13] cxgb3 - driver updates
Date: Fri, 10 Aug 2007 23:52:44 -0700
Message-ID: <200708110652.l7B6qiUv008711@speedy5.asicdesigners.com>
Cc: linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:9918 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbXHKGwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 02:52:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a patch series for inclusion in netdev#upstream.

Here is a brief description:
-       MAC hang workaround update
-       Modify max HW Rx coalescing size
-       Log SGE doorbell Fifo overflow
-       Use Tx immediate data for offload packets whenever possible
-       RDMA can get internal mem info to workaround HW issues
-       More validity checks on connection ids
-       Stop MAC when a fatal error is detected
-       Log HW serial number
-       Update internal mem operating mode
-       Update engine microcode management, version is now 1.1.0
-       Update FW management, version is now 4.6.0
-       Ignore some HW errors until the HW is initialized
-       Check MSI/MSI-X after it got enabled

Cheers,
Divy
