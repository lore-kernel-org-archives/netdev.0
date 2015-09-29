From: Christoffer Dall <christoffer.dall@linaro.org>
Subject: Re: BUG: Mellanox crash with iommu=soft and swiotlb=force
Date: Tue, 29 Sep 2015 09:04:14 +0200
Message-ID: <20150929070414.GA9002@cbox>
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
Received: from mail-la0-f48.google.com ([209.85.215.48]:36748 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932423AbbI2HEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 03:04:15 -0400
Received: by laclj5 with SMTP id lj5so91714880lac.3
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 00:04:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjGkNq3+Vu9WWuAt0CeRAGP2MTiTe+YeEOSGWLzucsu5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
> Are you running over ARM? which? if not, is that x86 64bit?
> 
I'm running on x86_64.

Thanks,
-Christoffer
