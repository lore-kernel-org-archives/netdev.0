From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Wed, 22 Dec 2004 20:31:38 -0800
Message-ID: <20041222203138.778fedb3.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Dec 2004 16:02:44 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> David, While the 2nd patch or something similar should be applied, I
> think the underlying cause of tg3_readphy() returning error should be
> further investigated.

Would this condition be possible if something, such as ASF, were
continually polling the PHY in parallel with the driver?

On the other hand, it doesn't seem so foreign for the PHY to
block out register accesses for long periods of time for various
reasons.

But yes I'd also like to know more about exactly what is going on
in this case.
