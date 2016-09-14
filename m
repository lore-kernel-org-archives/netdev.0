From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/9] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Wed, 14 Sep 2016 22:52:23 +0200
Message-ID: <20160914205223.GF12195@netboy>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-4-grygorii.strashko@ti.com>
 <20160914135214.GA28592@localhost.localdomain>
 <606f7cfc-aa34-528b-df04-7a60a9695425@ti.com>
 <20160914203217.GD12195@netboy>
 <c0aac71d-2033-f210-5494-15399b477e37@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c0aac71d-2033-f210-5494-15399b477e37@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 11:37:45PM +0300, Grygorii Strashko wrote:
> The problem is that if cpts not initialized than pinter on 
> cpts (in consumer/parent driver - NETCP) will be NULL.

You made that problem with your "clean up" in this series.
Previously, cpts was always allocated.

> So, rx_enable will be unaccessible and cause crash :(

So just make sure cpts is initialized.

Thanks,
Richard
