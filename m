From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Revert "ipv6: constify inet6_protocol structures"
Date: Tue, 01 Aug 2017 10:04:17 -0700 (PDT)
Message-ID: <20170801.100417.1363745993686752810.davem@davemloft.net>
References: <1501604849-19443-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, bhumirks@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501604849-19443-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue,  1 Aug 2017 18:27:27 +0200

> inet6_add_protocol and inet6_del_protocol include casts that remove the
> effect of the const annotation on their parameter, leading to possible
> runtime crashes.

Series applied, thanks for following up on this.
