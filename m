From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] __inet6_csk_dst_store(): fix check-after-use
Date: Mon, 15 Oct 2007 01:38:10 -0700 (PDT)
Message-ID: <20071015.013810.59671955.davem@davemloft.net>
References: <20071014175212.GP4211@stusta.de>
	<20071015113723.00F7.NAKAM@linux-ipv6.org>
	<20071015.123749.497715418.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, bunk@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47031
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755359AbXJOIiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:38:06 -0400
In-Reply-To: <20071015.123749.497715418.takamiya@po.ntts.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date: Mon, 15 Oct 2007 12:37:49 +0900 (JST)

> > 
> > On Sun, 14 Oct 2007 19:52:12 +0200
> > Adrian Bunk <bunk@kernel.org> wrote:
> > 
> > > The Coverity checker spotted that we have already oops'ed if "dst"
> > > was NULL.
> > > 
> > > Since "dst" being NULL doesn't seem to be possible at this point this 
> > > patch removes the NULL check.
> > > 
> > > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > 
> > Agreed.
> > 
> > Acked-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
>   I also agreed.
>   
> Acked-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

Patch applied, thanks everyone!
