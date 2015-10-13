From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] switchdev: check if the vlan id is in the proper
 vlan range
Date: Tue, 13 Oct 2015 04:45:02 -0700 (PDT)
Message-ID: <20151013.044502.487910723296948492.davem@davemloft.net>
References: <1444653061-5850-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, sfeldma@gmail.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbbJML3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 07:29:04 -0400
In-Reply-To: <1444653061-5850-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon, 12 Oct 2015 14:31:01 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> VLANs 0 and 4095 are reserved and shouldn't be used, add checks to
> switchdev similar to the bridge. Also make sure ids above 4095 cannot
> be passed either.
> 
> Fixes: 47f8328bb1a4 ("switchdev: add new switchdev bridge setlink")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
