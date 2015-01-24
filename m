From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] act_connmark: Add missing dependency on
 NF_CONNTRACK_MARK
Date: Fri, 23 Jan 2015 17:46:53 -0800 (PST)
Message-ID: <20150123.174653.1630115619853127599.davem@davemloft.net>
References: <eb5e12e8fec691cb08e663f2f8ed183ac92e5a1f.1421757793.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@openwrt.org, jhs@mojatatu.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbbAXBq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 20:46:56 -0500
In-Reply-To: <eb5e12e8fec691cb08e663f2f8ed183ac92e5a1f.1421757793.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 20 Jan 2015 13:44:25 +0100

> Depending on NETFILTER is not sufficient to ensure the presence of the
> 'mark' field in nf_conn, also needs to depend on NF_CONNTRACK_MARK.
> 
> Fixes: 22a5dc ("net: sched: Introduce connmark action")
> Cc: Felix Fietkau <nbd@openwrt.org>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
