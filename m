From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] dev: add per net_device packet type chains
Date: Tue, 27 Jan 2015 00:02:01 -0800 (PST)
Message-ID: <20150127.000201.1561369463873997294.davem@davemloft.net>
References: <1422043643-3265-1-git-send-email-noureddine@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, therbert@google.com, jiri@resnulli.us,
	vyasevic@redhat.com, netdev@vger.kernel.org, ebiederm@xmission.com
To: noureddine@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbbA0ICD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:02:03 -0500
In-Reply-To: <1422043643-3265-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@arista.com>
Date: Fri, 23 Jan 2015 12:07:23 -0800

>  	/* deliver only exact match when indicated */
> -	null_or_dev = deliver_exact ? skb->dev : NULL;
> +	if (likely(!deliver_exact)) {
> +		deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
> +				&ptype_base[ntohs(type) & PTYPE_HASH_MASK]);
> +	}

This is not indented properly.

A call that spans multiple lines should have the arguments on the
second and subsequent lines begin precisely at the first column
after the openning parenthesis on the first line.

Please fix this up and resubmit.
