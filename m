From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH  v2 09/13] net: ethernet: ti: cpts: clean up event list
 if event pool is empty
Date: Tue, 29 Nov 2016 11:13:43 +0100
Message-ID: <20161129101343.GH3110@localhost.localdomain>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
 <20161128230337.6731-10-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161128230337.6731-10-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 05:03:33PM -0600, Grygorii Strashko wrote:
> From: WingMan Kwok <w-kwok2@ti.com>
> 
> When a CPTS user does not exit gracefully by disabling cpts
> timestamping and leaving a joined multicast group, the system
> continues to receive and timestamps the ptp packets which eventually
> occupy all the event list entries.  When this happns, the added code
> tries to remove some list entries which are expired.
> 
> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

This patch belongs earlier in the series, before the re-structuring.
It doesn't depend on the others, AFAICT.

Thanks,
Richard
