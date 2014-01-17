From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/11] use ether_addr_equal_64bits
Date: Fri, 17 Jan 2014 22:24:10 +0100
Message-ID: <20140117212410.GA13930@amd.pavel.ucw.cz>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ath9k-devel@lists.ath9k.org, kernel-janitors@vger.kernel.org,
	ath5k-devel@lists.ath5k.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	users@rt2x00.serialmonkey.com
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 2013-12-30 19:14:56, Julia Lawall wrote:
> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
> used when each argument is an array within a structure that contains at
> least two bytes of data beyond the array.

I mean, yes, it is probably faster, and yes, most structures probably
contain two more bytes, but... is the uglyness worth the speedup? I'd
say this should not be done except in very time-critical places...
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
