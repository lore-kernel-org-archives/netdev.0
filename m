From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/tipc: fix potential null pointer dereference in
 several tipc netlink compat functions
Date: Mon, 23 May 2016 14:41:05 -0700 (PDT)
Message-ID: <20160523.144105.861691009093620479.davem@davemloft.net>
References: <6eb20dd0-0241-71d5-ee9e-0001db0301ba@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: sploving1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50576 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbcEWVlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 17:41:06 -0400
In-Reply-To: <6eb20dd0-0241-71d5-ee9e-0001db0301ba@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baozeng Ding <sploving1@gmail.com>
Date: Sun, 22 May 2016 00:22:48 +0800

> @@ -916,10 +970,16 @@ static int tipc_nl_compat_sk_dump(struct
> tipc_nl_compat_msg *msg,
>  static int tipc_nl_compat_media_dump(struct tipc_nl_compat_msg *msg,
>                       struct nlattr **attrs)
>  {
> +    int err;
>      struct nlattr *media[TIPC_NLA_MEDIA_MAX + 1];
> 

Local variable declarations shall be ordered from longest to shortest
line (also known as "reverse christmas tree format").

Please fix this up in your entire patch.

Also, please format your commit message properly to ~80 columns.  I
see a mix of long and very short lines, which means you were just adding
line breaks and not filling the rest of the line out to ~80 columns
as you should.

Thanks.
