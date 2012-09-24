From: Daniel Borkmann <dxchgb@gmail.com>
Subject: Re: [PATCH net-next] filter: add XOR instruction for use with X/K
Date: Mon, 24 Sep 2012 23:02:21 +0200
Message-ID: <20120924210220.GA31496@thinkbox>
References: <20120924122359.GB25156@thinkbox>
 <1348494228.26828.784.camel@edumazet-glaptop>
 <20120924.165005.1246466996061307302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:51217 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab2IXVC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 17:02:26 -0400
Received: by wibhq12 with SMTP id hq12so2451499wib.1
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 14:02:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120924.165005.1246466996061307302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> [2012-09-24 16:50:05 -0400] wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 24 Sep 2012 15:43:48 +0200
> > On Mon, 2012-09-24 at 14:23 +0200, Daniel Borkmann wrote:
> >> BPF_S_ANC_ALU_XOR_X has been added a while ago, but as an 'ancillary'
> >> operation that is invoked through a negative offset in K within BPF
> >> load operations. Since BPF_MOD has recently been added, BPF_XOR should
> >> also be part of the common ALU operations. Removing BPF_S_ANC_ALU_XOR_X
> >> might not be an option since this is exposed to user space.
> > 
> > Please note we dont expose BPF_S_ANC_ALU_XOR_X to user space.
> > 
> > We expose SKF_AD_ALU_XOR_X instead.
> > 
> > But it seems easier to leave it to keep this patch small (not touching
> > various JIT implementations, even if followup are welcomed)
> > 
> > Acked-by: Eric Dumazet <edumazet@google.com>
> 
> I applied this, fixing the commit message to refer to SKF_AD_ALU_XOR_X
> instead of BPF_S_ANC_ALU_XOR_X.

Thanks David!
