From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/2] cxgb3: Add Aeluros 2020 phy support
Date: Mon, 1 Jun 2009 11:53:50 +0100
Message-ID: <20090601105349.GF3051@decadent.org.uk>
References: <20090529075823.30669.28885.stgit@speedy5> <20090529075829.30669.41488.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38520 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757246AbZFAKxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 06:53:54 -0400
Content-Disposition: inline
In-Reply-To: <20090529075829.30669.41488.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-29 at 00:58 -0700, Divy Le Ray wrote:
[...]
> +	/* TWINAX EDC firmware */
> +	static u16 twinax_edc[] = {
> +		0xd800, 0x4009,
> +		0xd801, 0x2fff,
> +		0xd802, 0x300f,
> +		0xd803, 0x40aa,
> +		0xd804, 0x401c,
[...]

Use request_firmware() please.

Ben.

-- 
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindberg
