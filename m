From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2/9] pcmcia: use pre-determined values
Date: Tue, 27 Oct 2009 15:28:20 -0400
Message-ID: <20091027192820.GC15566@tuxdriver.com>
References: <1255907255-28297-1-git-send-email-linux@dominikbrodowski.net> <1255907255-28297-2-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pcmcia@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45159 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648AbZJ0TbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 15:31:15 -0400
Content-Disposition: inline
In-Reply-To: <1255907255-28297-2-git-send-email-linux@dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2009 at 01:07:28AM +0200, Dominik Brodowski wrote:
> A few PCMCIA network drivers can make use of values provided by the pcmcia
> core, instead of tedious, independent CIS parsing.
> 
> xirc32ps_cs.c: manf_id
> 
> hostap_cs.c: multifunction count
> 
> b43/pcmcia.c: ConfigBase address and "Present"
> 
> smc91c92_cs.c:  By default, mhz_setup() can use VERS_1 as it is stored
> in struct pcmcia_device. Only some cards require workarounds, such as
> reading out VERS_1 twice.
> 
> CC: David S. Miller <davem@davemloft.net>
> CC: John W. Linville <linville@tuxdriver.com>
> CC: netdev@vger.kernel.org
> CC: linux-wireless@vger.kernel.org
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
