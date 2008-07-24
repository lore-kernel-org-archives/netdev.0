From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Wed, 23 Jul 2008 23:45:56 -0700 (PDT)
Message-ID: <20080723.234556.98132946.davem@davemloft.net>
References: <BAY103-DAV1DBA31C9BCB4C6FFB3DE0B2870@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: pupilla@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751040AbYGXGp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 02:45:56 -0400
In-Reply-To: <BAY103-DAV1DBA31C9BCB4C6FFB3DE0B2870@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Marco Berizzi" <pupilla@hotmail.com>
Date: Thu, 24 Jul 2008 08:39:48 +0200

> Jul 23 12:40:02 Electra kernel: crond: page allocation failure. order:5,
> mode:0x4020
> Jul 23 12:40:02 Electra kernel: Pid: 586, comm: crond Not tainted 2.6.26
> #1
> Jul 23 12:40:02 Electra kernel:  [<c0135e93>]
> __alloc_pages_internal+0x226/0x393
> Jul 23 12:40:02 Electra kernel:  [<c0136007>] __alloc_pages+0x7/0x9
> Jul 23 12:40:02 Electra kernel:  [<c013602a>] __get_free_pages+0x16/0x32
> Jul 23 12:40:03 Electra kernel:  [<c024d2a5>]
> pskb_expand_head+0x41/0x164
> Jul 23 12:40:03 Electra kernel:  [<c029a6b4>]
> ipcomp_decompress+0x60/0xa1

ipcomp_decompress() should probably be changed to try and build
a scatterlist of pages for the resulting packet SKB data instead
of building a linear buffer as it does now.
