From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.8-rc3-mm1 1/2] 8139too: Rx fifo/overflow recovery
Date: Thu, 12 Aug 2004 00:32:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040811223243.GA8584@electric-eye.fr.zoreil.com>
References: <20040805234336.A15407@electric-eye.fr.zoreil.com> <411A70CB.8060101@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Pasi Sjoholm <ptsjohol@cc.jyu.fi>,
        Hector Martin <hector@marcansoft.com>,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <411A70CB.8060101@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> You _want_ to update those registers on every packet.  Otherwise the 
> crappy 8139 chip breaks.

The affected users noticed a clear difference when the update was in
the no-packet branch instead of the packet processing loop. Btw the
excerpt of the documentation outlined by Hirofumi san suggests that
this update makes sense.

Any objection/suggestion regarding a patch which would allow the update
in both branches ?

--
Ueimor
