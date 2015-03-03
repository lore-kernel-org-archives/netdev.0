From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Tue, 03 Mar 2015 12:18:29 +0100
Message-ID: <54F59885.1000203@freebox.fr>
References: <1425317290-1443-1-git-send-email-nschichan@freebox.fr> <20150302.221547.345365592649851304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: tklauser@distanz.ch, balbi@ti.com,
	w-lkml@lebenslange-mailadresse.de, ebiederm@xmission.com,
	alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150302.221547.345365592649851304.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 03/03/2015 04:15 AM, David Miller wrote:
> First, no signoff, that is required for your patch.

Hello David,

I realized that I had forgotten the signoff-by line too late unfortunately.

> Secondly, we strongly recommend that TX buffer reclaim be not
> accounted at all in the poll budget.
>
> Just do all of the TX work, unconditionally, every time the poll
> routine is invoked.  Do not add it into the work variable that
> gets compared against the budget.  Pretend it took '0' units of
> work.

I took inspiration from the mv643xx_eth driver which seems to account the tx
buffer reclaim in the work done in its poll callback. I'll send an updated patch.

Thanks,

-- 
Nicolas Schichan
Freebox SAS
