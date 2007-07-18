From: David Miller <davem@davemloft.net>
Subject: Re: IPSec freeze
Date: Wed, 18 Jul 2007 01:58:31 -0700 (PDT)
Message-ID: <20070718.015831.112851819.davem@davemloft.net>
References: <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local>
	<469BB50C.10203@trash.net>
	<469CE9E5.7040003@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Daniel.Beschorner@facton.com, netdev@vger.kernel.org,
	dada1@cosmosbay.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754164AbXGRI6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 04:58:32 -0400
In-Reply-To: <469CE9E5.7040003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 17 Jul 2007 18:10:13 +0200

> [XFRM]: Fix crash introduced by struct dst_entry reordering
> 
> XFRM expects xfrm_dst->u.next to be same pointer as dst->next, which
> was broken by the dst_entry reordering in commit 1e19e02c~, causing
> an oops in xfrm_bundle_ok when walking the bundle upwards.
> 
> Kill xfrm_dst->u.next and change the only user to use dst->next instead.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks a lot Patrick.

I'll toss this to -stable too.
