From: David Dillow <dave@thedillows.org>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: 06 Jun 2004 22:29:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086575392.4731.9.camel@ori.thedillows.org>
References: <20040606165322.GA13247@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040606165322.GA13247@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-06-06 at 12:53, Roger Luethi wrote:
> A bunch of other drivers are affected, too. I'll post a patch for
> 2.6 atp, winbond, and tulip_core (typhoon could be okay at first
> glance). Those are entirely untested due to lack of hardware.

I think typhoon's OK -- I calculate the filter on the host, and then do
a cpu_to_le32() on the final values, since the processor on the NIC is
in little-endian mode.

However, I've never tested it. I'll be happy to do so, if someone will
point me to appropriate code -- I've got an Ultra5 as well, so I can
test both big and little endian machines. Otherwise, I'll test it when I
get around to writing something, or someone reports a bug. :)

Dave
