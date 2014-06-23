From: Dave Chiluk <chiluk@canonical.com>
Subject: Stable request for 5882a07c72093d
Date: Mon, 23 Jun 2014 10:56:55 -0500
Message-ID: <1403539016-15519-1-git-send-email-chiluk@canonical.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	Wei-Chun Chao <weichunc@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38395 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755851AbaFWP5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 11:57:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5882a07c72093dc3a18e2d2b129fb200686bb6ee remedies a BUG_ON in
skb_segment.  This is hit reliably in clouds that are using openvswitch for
network capabilities (which is the default network used by Openstack) on
machines that have gso offload capabilities.  

This has already been reported multiple times to Canonical in numerous
openstack clouds.  The fix has been integrated and tested in those clouds, and
has been show to resolve their issues.

Please include this patch for stable release.

Thank you, 
Dave Chiluk

The patch follows for convenience.
