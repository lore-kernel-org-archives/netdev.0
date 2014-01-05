From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/6] phylib: cleanups
Date: Sun, 5 Jan 2014 09:31:10 +0100
Message-ID: <20140105083109.GB4933@netboy>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
 <20140104155338.GG4925@netboy>
 <52C8417D.6020502@cogentembedded.com>
 <52C858C7.1010300@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:44853 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaAEIbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 03:31:22 -0500
Received: by mail-ea0-f171.google.com with SMTP id h10so7445665eak.30
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 00:31:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52C858C7.1010300@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 04, 2014 at 09:53:59PM +0300, Sergei Shtylyov wrote:
> 
> >    Because get_maintainer.pl doesn't suggest it and because Andy Fleming
> >seems no longer interested in maintaining his code written back in 2004.

It never hurts to ask.

Your patches are saying, "Andy, your code has poor style." I don't
agree, especially about #3. Also, maybe the deleted callback will
useful one day. After all, there are not that many phylib
drivers. Perhaps future MAC drivers will need this.
 
>    Besides, I don't have his current email address (the source code
> doesn't provide any).

Here, let me find that for you.

Thanks,
Richard
---
git log --author="Andy Fleming"

commit 39fd40274d1f3a52152ae6fc22f428d93f1a8363
Author: Andy Fleming <afleming@freescale.com>
Date:   Mon Aug 5 14:58:35 2013 -0500

    powerpc: Convert platforms to smp_generic_cpu_bootable
    
    T4, Cell, powernv, and pseries had the same implementation, so switch
    them to use a generic version. A2 apparently had a version, but
    removed it at some point, so we remove the declaration, too.
    
    Signed-off-by: Andy Fleming <afleming@freescale.com>
    Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

commit 3cd852502316d42e3e75859e92d9f0a952bb55a2
Author: Andy Fleming <afleming@freescale.com>
Date:   Mon Aug 5 14:58:34 2013 -0500

    powerpc: Add smp_generic_cpu_bootable
    
    Cell and PSeries both implemented their own versions of a
    cpu_bootable smp_op which do the same thing (well, the PSeries
    one has support for more than 2 threads). Copy the PSeries one
    to generic code, and rename it smp_generic_cpu_bootable.
    
    Signed-off-by: Andy Fleming <afleming@freescale.com>
    Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
