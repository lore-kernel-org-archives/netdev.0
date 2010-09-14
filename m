From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH v4 00/10] split out emac cpdma and mdio for reuse
Date: Tue, 14 Sep 2010 16:10:48 -0700
Message-ID: <87k4mnj4zr.fsf@deeprootsystems.com>
References: <1284498612-25294-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1284498612-25294-1-git-send-email-cyril@ti.com> (Cyril
	Chemparathy's message of "Tue, 14 Sep 2010 17:10:02 -0400")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyril Chemparathy <cyril@ti.com> writes:

> Davinci's EMAC device has an in-built MDIO controller and a CPDMA engine.
> These hardware modules are not restricted to EMAC device alone.  For example,
> CPSW3G (3-port gigabit ethernet switch) hardware uses these very same modules
> internally.  This patch series separates out EMAC's MDIO and CPDMA
> functionality, allowing these individual pieces to be reused across TI
> hardware.  

[...]

> Changes from v3 (rolled in "post cpdma/mdio refactoring fixes" series):
>   1. allow forced 100/full mode instead of phy auto-detect
>   2. specify phy_id on boards that had a phy_mask defined earlier
>   3. requeue cpdma descriptors when EOQ at submit
>   4. use calculated mdio bus access times instead of hardcoded delays
>   5. work around emac soft-reset impact on mdio controller state
>   6. extend register dumps to include cpdma registers

Minor nit: you should remove the Michael's and Caglar's Tested-by on the
omap:* patches as I don't believe they tested those.  While you're at
it, please add Tony's ack.

Feel free to just update those two patches, and I'll queue up this
updated series.

Thanks,

Kevin
