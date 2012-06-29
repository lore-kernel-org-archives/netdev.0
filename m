From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] [net-next] Netlink updates
Date: Fri, 29 Jun 2012 16:42:33 -0700 (PDT)
Message-ID: <20120629.164233.882534874218646662.davem@davemloft.net>
References: <1340986522-3442-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340986522-3442-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Fri, 29 Jun 2012 18:15:20 +0200

> If you like them, please manually apply. I wanted to know if you are
> happy with these before pushing them into my tree, as they include
> netlink changes.

Looks great, both applied.

The interface can probably be extended further, if you notice all
callers pass in THIS_MODULE.  So you can have an inline wrapper
"netlink_kernel_create()" and passes the THIS_MODULE value down
into "__netlink_kernel_create()"
