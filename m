From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 3/6] new pcmcia IDs for hostap
Date: Wed, 17 May 2006 14:45:53 -0400
Message-ID: <20060517184548.GA17895@tuxdriver.com>
References: <200605161621.22459.linux-arm@hrw.one.pl> <200605161724.53495.linux-arm@hrw.one.pl> <1147814144.14914.38.camel@dv> <200605171036.05164.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>,
	Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:42510 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750919AbWEQSqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 14:46:24 -0400
To: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
Content-Disposition: inline
In-Reply-To: <200605171036.05164.linux-arm@hrw.one.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 17, 2006 at 10:36:03AM +0200, Marcin Juszkiewicz wrote:

> Platform: Sharp Zaurus C760 running 2.6.16 and pcmciautils 013.
> 
> root@c7x0:~# pccardctl ident
> Socket 0:
>   product info: "Pretec", "CompactWLAN Card 802.11b", "2.5"
>   manfid: 0x0156, 0x0002
>   function: 6 (network)
> 
> ==========================================================================
> From: Jochen Friedrich 
> 
> Yet another card known to work OK with hostap_cs:
> 
> # pccardctl ident
> Socket 0:
>   no product info available
> Socket 1:
>   product info: "U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
>   manfid: 0x0156, 0x0002
>   function: 6 (network)
> 
> ==========================================================================
> 
> Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>

If everyone is happy w/ this version of the patch, then please clean-up
the changelog appropriately and repost it cleanly according to the
format described here:

	http://linux.yyz.us/patch-format.html

Thanks,

John

P.S.  I think all that pccardctl output is overkill for the changelog
entry.  Simply name the cards covered by the patch.
-- 
John W. Linville
linville@tuxdriver.com
