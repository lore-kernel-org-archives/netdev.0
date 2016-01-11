From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: Re: [PATCH v2 0/3] can: sja1000: support for technologic version
Date: Mon, 11 Jan 2016 11:58:08 -0500
Message-ID: <20160111165807.GA7116@localhost>
References: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	kernel@savoirfairelinux.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Thu, Dec 24, 2015 at 12:42:50PM -0500, Damien Riegel wrote:
> This patchset introduces support for the technologic version of the
> SJA1000. Access to IP's registers are proxied through a window,
> requiring two bus accesses to read or write a register. These accesses
> must be protected by a spinlock to prevent race conditions. Currently,
> there is no easy way to allocate and initialize this spinlock.
> 
> SJA1000 already provides a way to allocate private data, but
> sja1000_platform.c makes no use of it.
> 
> Patch 1 adds the capability to allocate and initialize private data on a
> per-compatible basis in sja1000_platform.c.
> 
> Patch 2 updates device tree documentation to add the technologic
> version.
> 
> Patch 3 updates the driver to implement the technologic version
> 

Did you have a chance to take a look at this patchset? I would
appreciate your feedback, especially on the first patch.


Thanks,
Damien
