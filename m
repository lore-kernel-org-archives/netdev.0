From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] zd1211rw: Support AL7230B RF
Date: Mon, 14 Aug 2006 15:13:20 -0400
Message-ID: <20060814191314.GC13934@tuxdriver.com>
References: <20060812165946.27E418E776D@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:10514 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932501AbWHNTOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 15:14:04 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <20060812165946.27E418E776D@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2006 at 05:59:46PM +0100, Daniel Drake wrote:

> +	/* All of these writes are identical to AL2230 unless otherwise
> +	 * specified */
> +	static const struct zd_ioreq16 ioreqs_1[] = {
> +		/* This one is 7230-specific, and happens before the rest */
> +		{ CR240,  0x57 },
> +		{ },

I'm just curious about this line...what does it do for you?  A delay
of some sort?

> +
> +		{ CR15,   0x20 }, { CR23,   0x40 }, { CR24,  0x20 },
> +		{ CR26,   0x11 }, { CR28,   0x3e }, { CR29,  0x00 },
> +		{ CR44,   0x33 },

-- 
John W. Linville
linville@tuxdriver.com
