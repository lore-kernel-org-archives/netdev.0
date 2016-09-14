From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 8/9] net: ethernet: ti: cpts: fix overflow check period
Date: Wed, 14 Sep 2016 22:43:07 +0200
Message-ID: <20160914204307.GE12195@netboy>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-9-grygorii.strashko@ti.com>
 <20160914142503.GF28592@localhost.localdomain>
 <d4cde14a-8147-6097-f034-c9cde6cdb718@ti.com>
 <20160914200845.GB12195@netboy>
 <33f6f81b-ce41-4eba-c62d-93cdb06daa8f@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <33f6f81b-ce41-4eba-c62d-93cdb06daa8f@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 11:23:43PM +0300, Grygorii Strashko wrote:
> if yes then those changes are correct as from patch#7 point of 
> view, as from patch#8 because they are separate standalone changes.
> In patch patch#7 it reasonable to ball out earlier, while in patch#8
> it required to move forward a bit as I need to know maxsec. 

And what about the extra blank line?  AFAICT, placing the test later
in patch #7 is correct logic and has the advantage of not distracting
reviews with pointless churn!

Thanks,
Richard
