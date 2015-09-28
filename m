From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: BUG: Mellanox crash with iommu=soft and swiotlb=force
Date: Tue, 29 Sep 2015 00:59:35 +0300
Message-ID: <CAJ3xEMjGkNq3+Vu9WWuAt0CeRAGP2MTiTe+YeEOSGWLzucsu5A@mail.gmail.com>
References: <20150928210450.GA7610@cbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com,
	konrad.wilk@oracle.com, Eugenia Emantayev <eugenia@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Christoffer Dall <christoffer.dall@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35903 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbbI1V7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 17:59:36 -0400
Received: by ioii196 with SMTP id i196so191961096ioi.3
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 14:59:36 -0700 (PDT)
In-Reply-To: <20150928210450.GA7610@cbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 12:04 AM, Christoffer Dall
<christoffer.dall@linaro.org> wrote:
> Hi,
>
> In doing some performance experiments I found that using a 10G Mellanox
> MX354A Dual port FDR CX3 device on a server running Apache and running
> ab against that server causes the system to crash with 'iommu=soft
> swiotlb=force'.  The same behavior is seen without these options on Dom0
> running under Xen.
>
> I have tried this on v4.0 and v4.3-rc3.

Woops, needs looking indeed. Unfortunately many people in the team are
off for the Sukkot holiday with real backing to business coming to
play on Oct 6th -- not sure we can really respond on that before.

Are you running over ARM? which? if not, is that x86 64bit?

Or.

> Examples of crashes:
> http://pastebin.ubuntu.com/11953498/
> http://pastebin.ubuntu.com/11953443/
>
> Kernel config (v4.3):
> http://paste.ubuntu.com/12605446/
>
> To reproduce, host a file in apache server on a system with the Mellanox
> NIC (I used the 41K index file of the GCC manual) and run ab (apache
> bench) from a client machine, something like this:
>
> $ ab -n 100000 -c 100 http://10.10.1.2/gcc/index.html
>
> I'm afraid debugging this is out of my area of expertise.  Is this
> something you could have a look at?
>
>
> Thanks,
> -Christoffer
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
