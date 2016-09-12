From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 25/26] pch_gbe: constify local structures
Date: Mon, 12 Sep 2016 09:33:00 -0700 (PDT)
Message-ID: <20160912.093300.2115761736296247237.davem@davemloft.net>
References: <1473599168-30561-26-git-send-email-Julia.Lawall@lip6.fr>
        <20160911.194819.1394072668837372328.davem@davemloft.net>
        <alpine.DEB.2.10.1609121058580.3049@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1609121058580.3049@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Mon, 12 Sep 2016 11:07:15 +0200 (CEST)

> So foo is protected, but its lifetime of interest is quite short.  But we
> can't set the ops field of the type of xxx to be const either, because it
> is obviously not - the code above modifies it.

You can definitely make it a pointer to a const thing.

Just like "netdev_ops" in struct net_device is const.
