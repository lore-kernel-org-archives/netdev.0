From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: xt_TEE: fix NULL dereference
Date: Tue, 20 Oct 2015 12:19:45 +0200
Message-ID: <20151020101945.GA1832@salvia>
References: <1445302921.30896.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50526 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077AbbJTKMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 06:12:43 -0400
Content-Disposition: inline
In-Reply-To: <1445302921.30896.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 06:02:01PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> iptables -I INPUT ... -j TEE --gateway 10.1.2.3
> 
> <crash> because --oif was not specified
> 
> tee_tg_check() sets ->priv pointer to NULL in this case.

Applied here, will push it out after the pending pull request.

Thanks Eric.
