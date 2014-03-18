From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Tue, 18 Mar 2014 08:47:40 -0700
Message-ID: <20140318084740.729e21a6@nehalam.linuxnetplumber.net>
References: <201403181521.s2IFL99N027716@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:53330 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755536AbaCRPro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 11:47:44 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so7525960pbc.27
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 08:47:44 -0700 (PDT)
In-Reply-To: <201403181521.s2IFL99N027716@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Mar 2014 11:21:09 -0400
David L Stevens <dlstevens@us.ibm.com> wrote:

> +	struct sk_buff *reply = NULL;
> +	struct nd_msg *ns, *na;
> +	struct ipv6hdr *pip6 = ipv6_hdr(reply);

Redundant initialization of reply and pip6.
Doing ipv6_hdr(NULL) is bogus.
