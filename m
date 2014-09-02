From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [PATCH] openvswitch: distinguish between the dropped
 and consumed skb
Date: Tue, 2 Sep 2014 15:14:37 +0200
Message-ID: <20140902131437.GB14751@pox.localdomain>
References: <1409662369-2528-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63345 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbaIBNOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 09:14:41 -0400
Received: by mail-wi0-f178.google.com with SMTP id r20so7850879wiv.17
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 06:14:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1409662369-2528-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/14 at 08:52pm, roy.qing.li@gmail.com wrote:
> @@ -304,9 +303,11 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
>  	if (err)
>  		goto err;
>  
> +	consume_skb(skb);
>  	return 0;

What about the path from output_userspace()?
