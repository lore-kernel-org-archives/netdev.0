From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 net-next] tcp_metrics: fix wrong lockdep annotations
Date: Mon, 16 Mar 2015 22:27:49 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1503162213040.2343@ja.home.ssi.bg>
References: <20150316113542.GA27127@paralelels.com>  <1426514329.11398.204.camel@edumazet-glaptop2.roam.corp.google.com> <1426515274.11398.209.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Vagin <avagin@parallels.com>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55898 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933283AbbCPU3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 16:29:37 -0400
In-Reply-To: <1426515274.11398.209.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 16 Mar 2015, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Changes in tcp_metric hash table are protected by tcp_metrics_lock
> only, not by genl_mutex

	So, can we also use .parallel_ops = true in
tcp_metrics_nl_family ? Looks like commands do not use
genl_mutex in such case.

Regards

--
Julian Anastasov <ja@ssi.bg>
