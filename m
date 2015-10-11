From: Christoffer Dall <christoffer.dall@linaro.org>
Subject: Re: BUG: Mellanox crash with iommu=soft and swiotlb=force
Date: Sun, 11 Oct 2015 15:59:59 +0200
Message-ID: <20151011135959.GA2490@cbox>
References: <20150928210450.GA7610@cbox>
 <CAJ3xEMjGkNq3+Vu9WWuAt0CeRAGP2MTiTe+YeEOSGWLzucsu5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com,
	konrad.wilk@oracle.com, Eugenia Emantayev <eugenia@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33768 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbJKN7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 09:59:42 -0400
Received: by lbbk10 with SMTP id k10so8872469lbb.0
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 06:59:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjGkNq3+Vu9WWuAt0CeRAGP2MTiTe+YeEOSGWLzucsu5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Sep 29, 2015 at 12:59:35AM +0300, Or Gerlitz wrote:
> On Tue, Sep 29, 2015 at 12:04 AM, Christoffer Dall
> <christoffer.dall@linaro.org> wrote:
> > Hi,
> >
> > In doing some performance experiments I found that using a 10G Mellanox
> > MX354A Dual port FDR CX3 device on a server running Apache and running
> > ab against that server causes the system to crash with 'iommu=soft
> > swiotlb=force'.  The same behavior is seen without these options on Dom0
> > running under Xen.
> >
> > I have tried this on v4.0 and v4.3-rc3.
> 
> Woops, needs looking indeed. Unfortunately many people in the team are
> off for the Sukkot holiday with real backing to business coming to
> play on Oct 6th -- not sure we can really respond on that before.
> 
Friendly reminder on this one.  Did anyone have a look?

Thanks,
-Christoffer
