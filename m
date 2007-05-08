From: "Alexey Zaytsev" <alexey.zaytsev@gmail.com>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 8 May 2007 12:48:51 +0400
Message-ID: <f19298770705080148u70638ac2ue87241382681088@mail.gmail.com>
References: <464034CF.20700@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	"Michael Jones" <mlj28@cam.ac.uk>,
	"Krzysztof Halasa" <khc@pm.waw.pl>
To: "Tomasz Chmielewski" <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.228]:5067 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934714AbXEHIsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 04:48:53 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1891506wra
        for <netdev@vger.kernel.org>; Tue, 08 May 2007 01:48:53 -0700 (PDT)
In-Reply-To: <464034CF.20700@wpkg.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/8/07, Tomasz Chmielewski <mangoo@wpkg.org> wrote:
> Michael Jones wrote:
>
> >> +#ifndef __ARMEB__
> >> +#warning Little endian mode not supported
> >> +#endif
> >
> > Personally I'm less fussed about WAN / LE support. Anyone with any
> > sense will run ixp4xx boards doing such a specialised network
> > operation as BE. Also, NSLU2-Linux can't test this functionality with
> > our LE setup as we don't have this hardware on-board. You may just
> > want to declare a depends on ARMEB in Kconfig (with or without OR
> > (ARM || BROKEN) ) and have done with it - it's up to you.
>
> Christian Hohnstaedt's work did support LE though.
>
> Not all ixp4xx boards are by definition "doing such a specialised
> network operation".
>

I was always curious, why do people want to run ixp4xx in LE mode? What
are the benefits that overweight the obvious performance degradation?
