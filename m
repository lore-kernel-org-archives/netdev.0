From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH v4 00/10] split out emac cpdma and mdio for reuse
Date: Wed, 15 Sep 2010 07:54:03 -0700
Message-ID: <87aanjgir8.fsf@deeprootsystems.com>
References: <1284559890-31346-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, michael.williamson@criticallink.com,
	caglarakyuz@gmail.com, bparrot@ti.com
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1284559890-31346-1-git-send-email-cyril@ti.com> (Cyril
	Chemparathy's message of "Wed, 15 Sep 2010 10:11:20 -0400")
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
>   7. updated sign offs and acks

Thanks Cyril for one more spin with these updates.  Queuing this one for
2.6.37 in davinci-next.

davinci git is now updated with this series (may take a bit to propagate
to kernel.org mirrors though)

Kevin
