From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix multipart datapath dumps.
Date: Tue, 17 Jan 2012 23:56:35 -0500 (EST)
Message-ID: <20120117.235635.2253865702946442445.davem@davemloft.net>
References: <1326843219-14664-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, blp@nicira.com, paul@nicira.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757142Ab2ARE4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 23:56:39 -0500
In-Reply-To: <1326843219-14664-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 17 Jan 2012 15:33:39 -0800

> From: Ben Pfaff <blp@nicira.com>
> 
> The logic to split up the list of datapaths into multiple Netlink messages
> was simply wrong, causing the list to be terminated after the first part.
> Only about the first 50 datapaths would be dumped.  This fixes the
> problem.
> 
> Reported-by: Paul Ingram <paul@nicira.com>
> Signed-off-by: Ben Pfaff <blp@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
