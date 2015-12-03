From: David Miller <davem@davemloft.net>
Subject: Re: [v9, 3/6] fsl/fman: Add FMan MAC support
Date: Thu, 03 Dec 2015 15:23:42 -0500 (EST)
Message-ID: <20151203.152342.830757781812463540.davem@davemloft.net>
References: <1449127157-9400-1-git-send-email-igal.liberman@freescale.com>
	<1449127157-9400-4-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	madalin.bucur@freescale.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, ppc@mindchasers.com,
	stephen@networkplumber.org
To: igal.liberman@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449127157-9400-4-git-send-email-igal.liberman@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <igal.liberman@freescale.com>
Date: Thu, 3 Dec 2015 09:19:14 +0200

> +static u32 crc_table[256] = {

No way.

We have every conceivable implementation of CRC calculations in the
kernel already.  Use them.
