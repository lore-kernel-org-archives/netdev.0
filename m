From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Thu, 27 May 2004 02:04:43 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526160443.GD4557@sgi.com>
References: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2004 at 01:04:24PM -0700, Michael Chan wrote:
> [...] A few years ago we saw cases where there were tx completions
> on BDs that had not been sent. It turned out that on that machine, the
> chipset was re-ordering the posted mmio writes to the send mailbox
> register from 2 CPUs.[...]

On a related note, is there a good reason why the tg3 driver uses
the on-chip SRAM send ring by default instead of the host send ring?
This seems like it would dramatically increase the PIO load on the
chipset for some of the workloads I'm interested in.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
