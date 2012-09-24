From: Daniel Borkmann <dxchgb@gmail.com>
Subject: Re: [PATCH net-next] filter: add XOR instruction for use with X/K
Date: Mon, 24 Sep 2012 15:50:18 +0200
Message-ID: <20120924135017.GA26865@thinkbox>
References: <20120924122359.GB25156@thinkbox>
 <1348494228.26828.784.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41775 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132Ab2IXNuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 09:50:23 -0400
Received: by bkcjk13 with SMTP id jk13so921670bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 06:50:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1348494228.26828.784.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> [2012-09-24 15:43:48 +0200] wrote:
> On Mon, 2012-09-24 at 14:23 +0200, Daniel Borkmann wrote:
> > BPF_S_ANC_ALU_XOR_X has been added a while ago, but as an 'ancillary'
> > operation that is invoked through a negative offset in K within BPF
> > load operations. Since BPF_MOD has recently been added, BPF_XOR should
> > also be part of the common ALU operations. Removing BPF_S_ANC_ALU_XOR_X
> > might not be an option since this is exposed to user space.
> 
> Please note we dont expose BPF_S_ANC_ALU_XOR_X to user space.
> 
> We expose SKF_AD_ALU_XOR_X instead.

Indeed. Sorry for that typo.
 
> But it seems easier to leave it to keep this patch small (not touching
> various JIT implementations, even if followup are welcomed)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> 
