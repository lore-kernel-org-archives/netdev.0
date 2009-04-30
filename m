From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xt_socket: checks for the state of nf_conntrack
Date: Thu, 30 Apr 2009 09:39:09 -0700 (PDT)
Message-ID: <20090430.093909.157285653.davem@davemloft.net>
References: <1241105755-10017-1-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, mingo@elte.hu, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hidden@sch.bme.hu,
	linux-kernel@vger.kernel.org
To: panther@balabit.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1241105755-10017-1-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laszlo Attila Toth <panther@balabit.hu>
Date: Thu, 30 Apr 2009 17:35:55 +0200

> xt_socket can use connection tracking, and checks whether it is a module.
> 
> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>

I don't understand why we want what this is doing....

> +	depends on !NF_CONNTRACK || NF_CONNTRACK

This means that if NF_CONNTRACK is modular, it won't allow
the xt_socket code to be built.

However, all of this stuff should be buildable modular.
