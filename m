From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH 3/8] brcm80211: Add and use brcmX_dbg_dump_hex
Date: Sun, 15 Jan 2012 10:17:56 +0100
Message-ID: <4F1299C4.7020902@broadcom.com>
References: <cover.1326616556.git.joe@perches.com>
 <289e8a2dcdbb03315ba41788a358f5afc4bacb1b.1326616556.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Brett Rudley" <brudley@broadcom.com>,
	"Henry Ptasinski" <henryp@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"Kan Yan" <kanyan@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3048 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341Ab2AOJSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 04:18:06 -0500
In-Reply-To: <289e8a2dcdbb03315ba41788a358f5afc4bacb1b.1326616556.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2012 09:38 AM, Joe Perches wrote:

> +#ifdef DEBUG
> +extern __printf(3, 4)

Just curious if I can learn something here. What does the __printf(3, 4) do?

> +void brcmu_dbg_hex_dump(const void *data, size_t size, const char *fmt, ...);
> +#else
> +__printf(3, 4)
> +static inline
> +void brcmu_dbg_hex_dump(const void *data, size_t size, const char *fmt, ...)
> +{
> +}
> +#endif
> +
>  #endif				/* _BRCMU_UTILS_H_ */

Gr. AvS
