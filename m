From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: Gianfar breaks one of my test configs
Date: Sun, 24 Feb 2013 10:05:17 -0500
Message-ID: <CAP=VYLpjNHkYZL0aJXFshQ0fZY9yGpKN-8qhCzHARmKx=S9jFA@mail.gmail.com>
References: <1361717023.16950.12.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jianhua Xie <jianhua.xie@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, claudiu.manoil@freescale.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:48406 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434Ab3BXPFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 10:05:49 -0500
Received: by mail-wi0-f169.google.com with SMTP id l13so3723292wie.2
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2013 07:05:48 -0800 (PST)
In-Reply-To: <1361717023.16950.12.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 24, 2013 at 9:43 AM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> Hi folks !
>
> Current Linus tree as of this morning fails to build with one of my
> (semi-random) test configs (attached):
>
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c: In function 'gfar_netpoll':
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2909:32: error: 'struct gfar_priv_grp' has no member named 'interruptTransmit'

I see the problem - it wasn't tested with NET_POLL.   I'll have a fix
out shortly.

Thanks,
Paul.
--

> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2910:32: error: 'struct gfar_priv_grp' has no member named 'interruptReceive'
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2911:32: error: 'struct gfar_priv_grp' has no member named 'interruptError'
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2912:35: error: 'struct gfar_priv_grp' has no member named 'interruptTransmit'
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2914:31: error: 'struct gfar_priv_grp' has no member named 'interruptError'
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2915:31: error: 'struct gfar_priv_grp' has no member named 'interruptReceive'
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2916:31: error: 'struct gfar_priv_grp' has no member named 'interruptTransmit'
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2920:32: error: 'struct gfar_priv_grp' has no member named 'interruptTransmit'
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2921:35: error: 'struct gfar_priv_grp' has no member named 'interruptTransmit'
> /home/benh/linux-powerpc-test/drivers/net/ethernet/freescale/gianfar.c:2923:31: error: 'struct gfar_priv_grp' has no member named 'interruptTransmit'
> make[5]: *** [drivers/net/ethernet/freescale/gianfar.o] Error 1
> make[5]: *** Waiting for unfinished jobs....
>
> Cheers,
> Ben.
>
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
