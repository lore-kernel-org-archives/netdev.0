From: "Andrew Victor" <avictor.za@gmail.com>
Subject: Re: [PATCH] at91_ether: late collistions are counted twice
Date: Thu, 8 May 2008 21:40:21 +0200
Message-ID: <cd73a99e0805081240x4e697c5aq1c768ff888ce7d13@mail.gmail.com>
References: <200805081739.02489.marc.pignat@hevs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	linux@maxim.org.za
To: "Marc Pignat" <marc.pignat@hevs.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:64549 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbYEHTkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 15:40:22 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1130889rvb.1
        for <netdev@vger.kernel.org>; Thu, 08 May 2008 12:40:21 -0700 (PDT)
In-Reply-To: <200805081739.02489.marc.pignat@hevs.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

> According to the at91rm9200 datasheet, table 36-6, late collisions
> (AT91_EMAC_LCOL) are already counted in the collision register (in scol, mcol or
> ecol , depending on the type of error).
>
> So don't count them twice in stats.collisions.
>
> Signed-off-by: Marc Pignat <marc.pignat@hevs.ch>

Acked-by: Andrew Victor <linux@maxim.org.za>


Regards,
  Andrew Victor
