From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] constify inet6_protocol structures
Date: Fri, 28 Jul 2017 18:53:14 -0700 (PDT)
Message-ID: <20170728.185314.2227455199330921123.davem@davemloft.net>
References: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, bhumirks@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Fri, 28 Jul 2017 22:18:56 +0200

> The inet6_protocol structure is only passed as the first argument to
> inet6_add_protocol or inet6_del_protocol, both of which are declared as
> const.  Thus the inet6_protocol structure itself can be const.
> 
> Done with the help of Coccinelle.
 ...

Series applied, thanks Julia.
