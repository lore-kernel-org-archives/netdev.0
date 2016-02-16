From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] mpls: packet stats
Date: Tue, 16 Feb 2016 10:41:15 -0500 (EST)
Message-ID: <20160216.104115.1576720778383292937.davem@davemloft.net>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
	<1454700472-13543-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	ebiederm@xmission.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207AbcBPPlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:41:17 -0500
In-Reply-To: <1454700472-13543-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Statistics not provided via netlink are useless in real installations.

In fact I would say to forego the proc interface entirely, it's a second
class citizen for statistics gathering and has a non-triviel per-device
cost for instantiation.
