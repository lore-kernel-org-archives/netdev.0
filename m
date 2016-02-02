From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 1/4] net: add event_list to struct net and
 provide utility functions
Date: Tue, 2 Feb 2016 22:01:11 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1602022147330.2006@ja.home.ssi.bg>
References: <1454365952-10324-1-git-send-email-noureddine@arista.com> <1454365952-10324-2-git-send-email-noureddine@arista.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39989 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751976AbcBBUBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 15:01:48 -0500
In-Reply-To: <1454365952-10324-2-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 1 Feb 2016, Salam Noureddine wrote:

> +#ifdef CONFIG_NET_NS
> +static inline void net_add_event_list(struct list_head *head, struct net *net)
> +{
> +	if (!list_empty(&net->event_list))

	Above check looks inverted, it works may be
because INIT_LIST_HEAD(&net->event_list) is missing.

> +		list_add_tail(&net->event_list, head);
> +}
> +

Regards
