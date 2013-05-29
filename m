From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: use -EEXIST as return error to be more
 precise
Date: Tue, 28 May 2013 23:50:52 -0700 (PDT)
Message-ID: <20130528.235052.437523769251063741.davem@davemloft.net>
References: <1369722676-7898-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934364Ab3E2Gux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:50:53 -0400
In-Reply-To: <1369722676-7898-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Tue, 28 May 2013 14:31:16 +0800

> ovs_vport_cmd_new create a new vport with port num specified by user.
> when this port num is already occupied, it's more clear to return
> -EEXIST as the reason than -EBUSY.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Jesse?
