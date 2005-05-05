From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Mystery packet killing tg3
Date: Thu, 5 May 2005 14:42:01 -0700
Message-ID: <20050505144201.389edfd4.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3EB2@NT-IRVA-0741.brcm.ad.broadcom.com>
	<20050504155143.1a78cb7a@dxpl.pdx.osdl.net>
	<1115245822.15156.78.camel@rh4>
	<20050505113356.0f1b4c00.davem@davemloft.net>
	<1115322994.15156.98.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1115322994.15156.98.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 05 May 2005 12:56:34 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> On Thu, 2005-05-05 at 11:33 -0700, David S. Miller wrote:
> 
> > I'm very tempted to add a silencer to these messages in these
> > cases.  Something like the patch below.  Michael, what do you
> > think?
> > 
> > [TG3]: Elide tg3_stop_block messages when such events are normal.
> > 
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> 
> Looks good. I'm adding this patch to further ignore the tg3_stop_block
> errors.
> 
> [TG3]: Ignore tg3_stop_block() errors.
> 
> tg3_stop_block() errors can be safely ignored since tg3_chip_reset()
> always follows tg3_stop_block() calls.

Your email client wrapped the lines in the patch Michael, please use
attachments if you can't avoid this.

Anyways, I applied both my patch and your's (by hand) to my tree and
will push upstream.

Thanks again.
