From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [TRY2] Use nfmark as a key in u32 classifier
Date: Tue, 9 Nov 2004 14:30:35 +0100
Message-ID: <20041109133035.GH31969@postel.suug.ch>
References: <Pine.LNX.4.61.0411091406570.20094@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, lartc@mailman.ds9a.nl,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0411091406570.20094@webhosting.rdsbv.ro>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Catalin(ux aka Dino) BOIE <Pine.LNX.4.61.0411091406570.20094@webhosting.rdsbv.ro> 2004-11-09 14:27
> This is the try number two.
> What was changed:
> - Added selectable choice in Kconfig file (thanks Jamal!)
> - Don't abuse tc_u32_sel to not break backward compatibility (thanks 
> Patrick!).

Your patchs looks fine except for missing dependcy on CONFIG_NETFILTER.
Either make CLS_U32_MARK dependant on it or #ifdef the references
to skb->nfmark.

It might be fair to tell you that this code is likely to be removed
again once we have the metadata match.

Cheers
