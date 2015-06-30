From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] net: do not process device backlog during
 unregistration
Date: Tue, 30 Jun 2015 09:25:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506300913510.1508@ja.home.ssi.bg>
References: <1435420971-19263-1-git-send-email-ja@ssi.bg> <876167wt2p.fsf@x220.int.ebiederm.org> <alpine.LFD.2.11.1506292241230.1739@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:60663 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750750AbbF3GZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 02:25:27 -0400
In-Reply-To: <alpine.LFD.2.11.1506292241230.1739@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 29 Jun 2015, Julian Anastasov wrote:

> RFC patch:
> 
> Subject: [PATCHv2 net] net: do not process device backlog during
>  unregistration

	Ignore this v2, packets in backlog do not hold
dev reference, I'll prepare new version with such check
in enqueue_to_backlog. Also, it is process_backlog that
should start the RCU read section because packets may
escape the last synchronize_net... more fixes are needed.

Regards

--
Julian Anastasov <ja@ssi.bg>
