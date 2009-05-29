From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet
 transmission when polling with KGDB
Date: Fri, 29 May 2009 04:27:26 -0700 (PDT)
Message-ID: <20090529.042726.135473158.davem@davemloft.net>
References: <8bd0f97a0905290346v542e83cdg321241f0b4d95d9e@mail.gmail.com>
	<20090529.035224.124353374.davem@davemloft.net>
	<8bd0f97a0905290420g454c3affr21b6f05e5971d93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com, cooloney@kernel.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752664AbZE2L10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:27:26 -0400
In-Reply-To: <8bd0f97a0905290420g454c3affr21b6f05e5971d93@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 29 May 2009 07:20:18 -0400

> that isnt how the DMA is being used here.  there is no register to
> read back because the DMA controller is doing the reading indirectly.
> but along those lines, it's not entirely clear which DMA registers
> this SSYNC is supposed to be protecting because all of the updates are
> happening on the descriptors in external memory, not the DMA registers
> themselves.  i'll have Sonic clarify.

Yes, that's really confusing because the commit message says
"registers".
