From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RESEND] iproute2: GRE over IPv6 tunnel support.
Date: Mon, 30 Sep 2013 21:41:07 -0700
Message-ID: <20130930214107.0230d67b@nehalam.linuxnetplumber.net>
References: <20130928113251.75738a49@comp1>
	<20130928212752.GE23654@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dmitry Kozlov <xeb@mail.ru>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:40456 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab3JAEqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:46:48 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so6531129pbc.36
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 21:46:48 -0700 (PDT)
In-Reply-To: <20130928212752.GE23654@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Sep 2013 23:27:52 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Sat, Sep 28, 2013 at 11:32:51AM +0400, Dmitry Kozlov wrote:
> > GRE over IPv6 tunnel support.
> > 
> > Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> 
> Dmitry, thanks a lot for resending!
> 
> One small nit:
> 
> lib/ll_types.c would need a new entry in ll_type_n2a for ARPHDR_IP6GRE
> so ip link ls can pretty print the link type.
> 

Ok, fixed
