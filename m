From: Stefan Rompf <srompf@isg.de>
Subject: Re: Flush Tx skbs after link down
Date: Wed, 15 Jan 2003 10:57:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E253096.9F9DB6FE@isg.de>
References: <C6F5CF431189FA4CBAEC9E7DD5441E01087ADF@orsmsx402.jf.intel.com> <3E252EE9.D8CA8EDC@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com,
   "Cramer, Jeb J" <jeb.j.cramer@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> I think this can't be achieved without driver support, simply because
> pending DMA transfers must be removed before freeing the skbs, and this
> is specific. So the driver model needs to be extended to have a reset

PS: We also need to avoid that new skbs are enqueued while the link is
down without making the critical code path in dev_queue_xmit() much
longer. Right now, I don't have any ideas beyond a proof of concept for
this part.

Stefan
