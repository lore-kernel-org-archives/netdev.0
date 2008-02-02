From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] [RFC] 3c509: convert to isa_driver and pnp_driver v2
Date: Sat, 2 Feb 2008 23:07:20 +0200
Message-ID: <84144f020802021307ja672fdfl29e54483e9f900d@mail.gmail.com>
References: <200801312012.43447.linux@rainbow-software.org>
	 <200802021925.36552.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"Jeff Garzik" <jeff@garzik.org>
To: "Ondrej Zary" <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:18228 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756402AbYBBVHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 16:07:21 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1096121rvb.1
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2008 13:07:20 -0800 (PST)
In-Reply-To: <200802021925.36552.linux@rainbow-software.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Feb 2, 2008 8:25 PM, Ondrej Zary <linux@rainbow-software.org> wrote:
> +//static __be16 el3_phys_addr[EL3_MAX_CARDS][3];

[snip]

> +//#if defined(CONFIG_MCA) || defined(CONFIG_EISA)

[snip]

> +//     while (el3_probe(el3_cards) == 0) {
> +//             if (irq[el3_cards] > 1)
> +//                     el3_root_dev->irq = irq[el3_cards];
> +//             if (xcvr[el3_cards] >= 0)
> +//                     el3_root_dev->if_port = xcvr[el3_cards];
> +//             el3_cards++;
> +//     }

You might want to consider dropping these hunks...
