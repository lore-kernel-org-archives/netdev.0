From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHn net-next] vxlan: Improve support for header flags
Date: Mon, 12 Jan 2015 16:06:13 -0500 (EST)
Message-ID: <20150112.160613.1458330680465252967.davem@davemloft.net>
References: <1420749078-18913-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbbALVGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:06:16 -0500
In-Reply-To: <1420749078-18913-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu,  8 Jan 2015 12:31:18 -0800

> This patch cleans up the header flags of VXLAN in anticipation of
> defining some new ones:
> 
> - Move header related definitions from vxlan.c to vxlan.h
> - Change VXLAN_FLAGS to be VXLAN_HF_VNI (only currently defined flag)
> - Move check for unknown flags to after we find vxlan_sock, this
>   assumes that some flags may be processed based on tunnel
>   configuration
> - Add a comment about why the stack treating unknown set flags as an
>   error instead of ignoring them
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
