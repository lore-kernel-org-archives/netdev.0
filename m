From: Matthias Kaehlcke <matthias@kaehlcke.net>
Subject: Re: FEC driver: rcv is not +last
Date: Fri, 9 Apr 2010 10:17:59 +0200
Message-ID: <20100409081759.GR29538@darwin>
References: <20100408104033.GI3787@darwin>
 <4BBEBE57.8020800@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:40092 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050Ab0DIITl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:19:41 -0400
Content-Disposition: inline
In-Reply-To: <4BBEBE57.8020800@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bryan,

El Fri, Apr 09, 2010 at 01:42:47PM +0800 Bryan Wu ha dit:

> On 04/08/2010 06:40 PM, Matthias Kaehlcke wrote:
> >hi,
> >
> >i have problems with the FEC on a i.MX25 3-Stack board. the kernel is
> >v2.6.34-rc2 plus the following patch:
> >http://patchwork.ozlabs.org/patch/41235/
> >
> >the following traces are generated at boot time:
> >
> >FEC Ethernet Driver
> >fec: PHY @ 0x1, ID 0x20005ce1 -- unknown PHY!
> >...

> please try this patch on your hardware, it introduced phylib
> supporting in fec.c driver:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2010-March/012214.html

sascha pointed me yesterday to your patch, i tried it with v2
(http://lkml.org/lkml/2010/3/31/130), but without success.

our distributor informed us that the board they let us is a
preliminary hardware version and that this is probably the cause of
the problem :/

i hope i'll get soon my hands on an offical board release and can
verify that the FEC just works ;)

thanks for your help!

-- 
Matthias Kaehlcke
Embedded Linux Developer
Barcelona

               If sharing a thing in no way diminishes it,
               it is not rightly owned if it is not shared
                                                                 .''`.
    using free software / Debian GNU/Linux | http://debian.org  : :'  :
                                                                `. `'`
gpg --keyserver pgp.mit.edu --recv-keys 47D8E5D4                  `-
