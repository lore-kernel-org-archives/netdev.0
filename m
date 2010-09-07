From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH v2 00/10] split out emac cpdma and mdio for reuse
Date: Tue, 07 Sep 2010 08:23:43 -0700
Message-ID: <87aantk268.fsf@deeprootsystems.com>
References: <1283465008-18606-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, nsekhar@ti.com, srk@ti.com,
	omar.ramirez@ti.com, bparrot@ti.com,
	Cyril Chemparathy <cyril@ti.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1283465008-18606-1-git-send-email-cyril@ti.com> (Cyril
	Chemparathy's message of "Thu, 2 Sep 2010 18:03:18 -0400")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyril Chemparathy <cyril@ti.com> writes:

> Davinci's EMAC device has an in-built MDIO controller and a CPDMA engine.
> These hardware modules are not restricted to EMAC device alone.  For example,
> CPSW3G (3-port gigabit ethernet switch) hardware uses these very same modules
> internally.  This patch series separates out EMAC's MDIO and CPDMA
> functionality, allowing these individual pieces to be reused across TI
> hardware.  

Tony,

The AM3517 also uses this davinci EMAC driver and is modified by this
series.   With your ack, I'll merge the OMAP changes along with this
series via the davinci tree. 

OK with you?

Kevin

