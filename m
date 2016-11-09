From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH net v2 2/4] net: ethernet: ti: cpsw: fix device and
 of_node leaks
Date: Wed, 9 Nov 2016 10:58:25 +0100
Message-ID: <20161109095825.GE14744@localhost>
References: <1478194822-29545-1-git-send-email-johan@kernel.org>
 <1478194822-29545-3-git-send-email-johan@kernel.org>
 <0c76f9db-ab5f-bce3-897d-5f325c2b84c4@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:32775 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbcKIJ6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 04:58:37 -0500
Content-Disposition: inline
In-Reply-To: <0c76f9db-ab5f-bce3-897d-5f325c2b84c4@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 08, 2016 at 05:19:29PM -0600, Grygorii Strashko wrote:
> 
> 
> On 11/03/2016 12:40 PM, Johan Hovold wrote:
> > Make sure to drop the references taken by of_get_child_by_name() and
> > bus_find_device() before returning from cpsw_phy_sel().
> >
> > Note that holding a reference to the cpsw-phy-sel device does not
> > prevent the devres-managed private data from going away.
> >
> > Fixes: 5892cd135e16 ("drivers: net: cpsw-phy-sel: Add new driver...")
> > Cc: Mugunthan V N <mugunthanvnm@ti.com>
> > Cc: Grygorii Strashko <grygorii.strashko@ti.com>
> > Cc: linux-omap@vger.kernel.org
> > Signed-off-by: Johan Hovold <johan@kernel.org>
> > ---
> 
> Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

Thanks for the review. Note that David has already applied these, though.

Johan
