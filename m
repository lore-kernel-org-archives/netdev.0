From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Tue, 03 Mar 2015 14:03:03 -0500 (EST)
Message-ID: <20150303.140303.1041460094574986792.davem@davemloft.net>
References: <1425317290-1443-1-git-send-email-nschichan@freebox.fr>
	<20150302.221547.345365592649851304.davem@davemloft.net>
	<54F59885.1000203@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklauser@distanz.ch, balbi@ti.com,
	w-lkml@lebenslange-mailadresse.de, ebiederm@xmission.com,
	alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nschichan@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F59885.1000203@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Tue, 03 Mar 2015 12:18:29 +0100

> I took inspiration from the mv643xx_eth driver which seems to
> account the tx buffer reclaim in the work done in its poll callback.

It also should be fixed to not do so.
