From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP splice
Date: Mon, 24 Jun 2013 11:33:24 -0700
Message-ID: <1372098804.3301.77.camel@edumazet-glaptop>
References: <CACYKsS7pMFNdBxU2raMphKyb1zU7MEbhc=vsD+FdZ5sgFq71NQ@mail.gmail.com>
	 <1372088554.1896.3.camel@bwh-desktop.uk.level5networks.com>
	 <20130624155154.GD10413@order.stressinduktion.org>
	 <1372089776.1896.9.camel@bwh-desktop.uk.level5networks.com>
	 <20130624170119.GE10413@order.stressinduktion.org>
	 <CACYKsS5uy6nGbtCYit0eNyBSemzimgLrVdUJAgeBmZwDAy7F-A@mail.gmail.com>
	 <1372096418.3301.75.camel@edumazet-glaptop>
	 <CACYKsS4brDSL4gWGV8Aw455qqa-mdhE_=C7pFS-V=qaA7FBa6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Ricardo Landim <ricardolan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:40062 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab3FXSdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 14:33:22 -0400
Received: by mail-ea0-f175.google.com with SMTP id z7so6272690eaf.34
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 11:33:20 -0700 (PDT)
In-Reply-To: <CACYKsS4brDSL4gWGV8Aw455qqa-mdhE_=C7pFS-V=qaA7FBa6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 15:08 -0300, Ricardo Landim wrote:
> Help in zero copy and improve in cost of syscalls.
> 
> In my intel xeon(3.3ghz), read udp socket and write udp socket (proxy)
> spends ~40000 cycles (~12 us).
> 

splice() wont reduce number of syscalls.

If payload is small, copying it is less than 1000 cycles, so its a small
part of the cost you measured.
