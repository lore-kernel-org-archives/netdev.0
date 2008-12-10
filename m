From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/11] benet: hardware host interface header files
Date: Tue, 09 Dec 2008 22:49:04 -0800 (PST)
Message-ID: <20081209.224904.181841905.davem@davemloft.net>
References: <1228832449.6435.101.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, subbus@serverengines.com
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751013AbYLJGtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 01:49:03 -0500
In-Reply-To: <1228832449.6435.101.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 09 Dec 2008 19:50:49 +0530

> +} __packed;

Packed is pointless for datastructures containing only
8-bit integers.

> +	u8 interrupt32;	/* DWORD 0 */
> +	u8 interrupt33;	/* DWORD 0 */
> +	u8 interrupt34;	/* DWORD 0 */
> +	u8 interrupt35;	/* DWORD 0 */
> +	u8 interrupt36;	/* DWORD 0 */
> +	u8 interrupt37;	/* DWORD 0 */
> +	u8 interrupt38;	/* DWORD 0 */
> +	u8 interrupt39;	/* DWORD 0 */
> +	u8 interrupt40;	/* DWORD 0 */
> +	u8 interrupt41;	/* DWORD 0 */
> +	u8 interrupt42;	/* DWORD 0 */
> +	u8 interrupt43;	/* DWORD 0 */

Why do all of these comments say "DWORD 0"?  It can't
mean that the member is at offset "DWORD 0", there
are too many of these bytes to stay in DWORD 0.
