From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: bridge: refcount fix
Date: Mon, 24 Aug 2009 19:38:36 +0200
Message-ID: <4A92D01C.9050901@trash.net>
References: <4A92CB67.1080401@gmail.com> <4A92CC71.2000300@trash.net> <4A92CEA4.6020604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Bart De Schuymer <bdschuym@pandora.be>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57039 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbZHXRih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 13:38:37 -0400
In-Reply-To: <4A92CEA4.6020604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> [PATCH] netfilter: bridge: refcount fix
> 
> commit f216f082b2b37c4943f1e7c393e2786648d48f6f
> ([NETFILTER]: bridge netfilter: deal with martians correctly)
> added a refcount leak on in_dev.
> 
> Instead of using in_dev_get(), we can use __in_dev_get_rcu(),
> as netfilter hooks are running under rcu_read_lock(), as pointed
> by Patrick.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

I've applied it to nf-next-2.6.git since its not as EARTH SHATTERING
as I understood Dave would like it to be for consideration for
net-2.6.git :)

Thanks!
