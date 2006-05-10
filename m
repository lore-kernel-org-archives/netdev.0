From: s.munaut@intopix.com
Subject: Re: Hardware flow control on RTL8169
Date: Wed, 10 May 2006 15:13:25 +0200
Message-ID: <1147266805.4461e6f5ddd04@ssl0.ovh.net>
References: <1147099047.445f57a7874d4@ssl0.ovh.net> <20060508194625.GA15174@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([213.186.37.103]:59605 "EHLO
	25.mail-out.ovh.net") by vger.kernel.org with ESMTP id S964939AbWEJNN4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 09:13:56 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060508194625.GA15174@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

Selon Francois Romieu <romieu@fr.zoreil.com>:

> s.munaut@intopix.com <s.munaut@intopix.com> :
> [...]
> > I'm using a kurobox (www.kurobox.com) with a 2.6.15 kernel and I'd like to
> use
> > hardware flow control with it. However it seems the driver doesn't support
> it,
> > is that correct ?
> >
> > At least I see the device continue sending even when the other device is
> > sending PAUSE frames with 0xffff pausetime continuously.
> >
> > I've tried adding RTL_W16(TBI_ANAR, 0x00a0); to the hw_start function but
> > that doesn't seem to have any effect ...
> >
> > Any clue ?
>
> - use netdev@vger.kernel.org instead of netdev@oss.sgi.com

Sorry about that ... I don't know what version of MAINTAINER I looked at
to come up with that address ...

> - don't trim the Cc: (just a remainder...);
> - try the hack below with and without the first hunk. Use 'ethtool -s ethX'
>   to see what the device reports. It may not settle immediately.
>
>    [...diff snipped...]

Thanks, I'll try that.


Regards,

    Sylvain
