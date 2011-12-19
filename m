From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net/sched: sch_plug - Queue traffic until an explicit
 release command
Date: Mon, 19 Dec 2011 13:32:45 -0800
Message-ID: <20111219133245.2698e711@nehalam.linuxnetplumber.net>
References: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	Brendan Cully <brendan@cs.ubc.ca>
To: rshriram@cs.ubc.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50115 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218Ab1LSVcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 16:32:48 -0500
In-Reply-To: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Dec 2011 13:22:32 -0800
rshriram@cs.ubc.ca wrote:

> +
> +static int skb_remove_foreign_references(struct sk_buff *skb)
> +{
> +	return !skb_linearize(skb);
> +}
> +

This is silly. Just make qdisc work with fragmented skb's.
