From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net-next 02/10] net: netcp: ethss: add support of 10gbe
 pcsr link status
Date: Thu, 22 Dec 2016 16:30:13 -0600
Message-ID: <20161222223013.5ho6hn3tokvn3btz@rob-hp-laptop>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
 <1482271793-7671-3-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        grygorii.strashko@ti.com, mugunthanvnm@ti.com,
        linux-kernel@vger.kernel.org, arnd@arndb.de, davem@davemloft.net,
        devicetree@vger.kernel.org, mark.rutland@arm.com
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1482271793-7671-3-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 05:09:45PM -0500, Murali Karicheri wrote:
> From: WingMan Kwok <w-kwok2@ti.com>
> 
> The 10GBASE-R Physical Coding Sublayer (PCS-R) module provides
> functionality of a physical coding sublayer (PCS) on data being
> transferred between a demuxed XGMII and SerDes supporting a 16
> or 32 bit interface.  From the driver point of view, whether
> a ethernet link is up or not depends also on the status of the
> block-lock bit of the PCSR.  This patch adds the checking of that
> bit in order to determine the link status.

I would think this would be a common thing and the phy driver should 
provide the status, rather than trying to give the ethernet driver 
direct access to the phy registers. Is the PCSR the serdes phy or 
registers in addition to that?

Rob
