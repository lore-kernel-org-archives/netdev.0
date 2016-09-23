From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 22:22:14 +0200
Message-ID: <20160923202214.kvnmvkc7abi5oj23@pengutronix.de>
References: <troy.kisky@boundarydevices.com>
 <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
 <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
 <20160923173751.GA1041@n2100.armlinux.org.uk>
 <d0d6f333-c6fc-6572-0633-d7c2c29b8b3f@nelint.com>
 <20160923183725.GC1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Eric Nelson <eric@nelint.com>, Fugang Duan <fugang.duan@nxp.com>,
        Otavio Salvador <otavio@ossystems.com.br>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Eric Dumazet <edumazet@google.com>,
        Simone <cjb.sw.nospam@gmail.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, kernel@pengutronix.de
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:56366 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759965AbcIWUWX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 16:22:23 -0400
Content-Disposition: inline
In-Reply-To: <20160923183725.GC1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Russell,

On Fri, Sep 23, 2016 at 07:37:25PM +0100, Russell King - ARM Linux wrote:
> On Fri, Sep 23, 2016 at 11:26:18AM -0700, Eric Nelson wrote:
> > So the question is: should we just live with this and acknowledge a
> > performance penalty of bad alignment or do something about it?
> 
> Well, I've no interest in trying to do anything with the FEC driver
> anymore, as I'll just generate another big patch stack which won't
> make it into the kernel in a timely fashion - my last attempt at
> improving the FEC driver was dogged with conflicting changes and I
> gave up with it in the end.  I ended up spending a full cycle
> rebasing, re-testing, and re-evaluating their performance only to find
> that I'd missed the merge window again, and other conflicting changes
> got merged which meant that I had to start from the beginning again.

I'm not included in the set of people who are responsible to review and
merge fec patches, but I'd be surprised if you couldn't get an exclusive
lock for that driver. Something like: After 4.X-rc1 the fec isn't
touched any more until you got your series ready for the 4.X+1 merge
window. Of course some fixes might have to go in, but these hopefully
won't disturb much.

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
