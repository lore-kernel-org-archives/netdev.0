From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 00/15] Simplify netfilter and network
 namespaces
Date: Thu, 18 Jun 2015 22:21:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506182210240.1659@ja.home.ssi.bg>
References: <87616ppt3h.fsf@x220.int.ebiederm.org> <alpine.LFD.2.11.1506172216440.2649@ja.home.ssi.bg> <87wpz25a2q.fsf@x220.int.ebiederm.org> <alpine.LFD.2.11.1506180055030.3621@ja.home.ssi.bg> <87fv5p2hzg.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51699 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752639AbbFRTVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 15:21:17 -0400
In-Reply-To: <87fv5p2hzg.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 18 Jun 2015, Eric W. Biederman wrote:

> My incremental patch for ipvs on top of everything else I have pushed
> out looks like this:
> 
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> Date: Fri, 12 Jun 2015 18:34:12 -0500
> Subject: [PATCH] ipvs: Pass struct net down to where it is needed and used
> 
> Pass struct net down to where it is used and stop guessing
> which network namespace should be used.

	At first look patch is ok. But I'm not sure
for the changes in ip_vs_xmit.c. Can you explain in
2-3 lines, when can we see different netns? Is it when
packet is forwarded to output device and it is part from
another netns?

	I'm asking because these __ip_vs_get_out_rt*
calls in ip_vs_xmit.c can reroute packet to another
device...

	Also, skb_sknet is another candidate for removal.
But I can take care about it after your changes are
pushed...

Regards

--
Julian Anastasov <ja@ssi.bg>
