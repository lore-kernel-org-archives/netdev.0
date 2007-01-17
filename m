From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 16:43:28 +0100
Message-ID: <20070117164328.47ab60da@griffin.suse.cz>
References: <20070116185524.GA5681@dmt>
	<20070117141103.0e468bf4@griffin.suse.cz>
	<1169046072.2750.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:56819 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932503AbXAQPna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 10:43:30 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1169046072.2750.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Jan 2007 10:01:12 -0500, Dan Williams wrote:
> But could we please be constructive here, and actually take a look at
> the driver and point out problems?

Just from a quick glance:

- drivers/net/wireless/libertas/radiotap.h file with a lot of constants
  already defined elsewhere (and not respecting kernel coding style,
  either)
- regulatory domain management (already in ieee80211, in progress for
  d80211)
- the full authentication and association state machine (or am I
  understanding it wrong?)

And I'm omitting things like

> +/** Double-Word(32Bit) Bit definition */
> +#define DW_BIT_0	0x00000001
> +#define DW_BIT_1	0x00000002
> +#define DW_BIT_2	0x00000004
> +#define DW_BIT_3	0x00000008
> +#define DW_BIT_4	0x00000010
> +#define DW_BIT_5	0x00000020
> +#define DW_BIT_6	0x00000040
> +#define DW_BIT_7	0x00000080
> +#define DW_BIT_8	0x00000100
> +#define DW_BIT_9	0x00000200
> +#define DW_BIT_10	0x00000400
> +#define DW_BIT_11       0x00000800
> +#define DW_BIT_12       0x00001000
> +#define DW_BIT_13       0x00002000
> +#define DW_BIT_14       0x00004000
> +#define DW_BIT_15       0x00008000
> +#define DW_BIT_16       0x00010000
> +#define DW_BIT_17       0x00020000
> +#define DW_BIT_18       0x00040000
> +#define DW_BIT_19       0x00080000
> +#define DW_BIT_20       0x00100000
> +#define DW_BIT_21       0x00200000
> +#define DW_BIT_22       0x00400000
> +#define DW_BIT_23       0x00800000
> +#define DW_BIT_24       0x01000000
> +#define DW_BIT_25       0x02000000
> +#define DW_BIT_26       0x04000000
> +#define DW_BIT_27       0x08000000
> +#define DW_BIT_28       0x10000000
> +#define DW_BIT_29       0x20000000
> +#define DW_BIT_30	0x40000000
> +#define DW_BIT_31	0x80000000

or those ENTER and LEAVE statements in each other function,
non-conforming coding style, comments like "All rights reserved" or
"This software file (the "File") is distributed by Marvell
International Ltd.", a lot of duplicated code, etc. I stopped looking
at it in the half, sorry.

 Jiri

-- 
Jiri Benc
SUSE Labs
