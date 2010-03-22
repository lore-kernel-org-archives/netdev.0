From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Add PGM protocol support to the IP stack
Date: Mon, 22 Mar 2010 09:24:14 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1003220921110.15360@router.home>
References: <alpine.DEB.2.00.1003181245050.23010@router.home> <87tysccjrn.fsf@basil.nowhere.org> <20100319.145336.226782717.davem@davemloft.net> <4BA3FA1D.8050204@zytor.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BA3FA1D.8050204@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Mar 2010, H. Peter Anvin wrote:

> On 03/19/2010 02:53 PM, David Miller wrote:
> > But I also don't consider what openpbm has to do right now to
> > be all that much of a restriction.  You need privileges to
> > add the protocol to the kernel, you need privileges to run
> > the userspace variant, there is no real difference.
>
> The real difference is if multiplex is needed between multiple
> unprivileged users.

It is needed. PGM ports exist and work similarly to UDP and TCP ports.

PGM as provided by openpgm and other solutions avoids native PGM and
instead uses PGM over UDP. But the routers do not support PGM over UDP in
the same way as native PGM. So the NAK suppression and other advanced
features available in Juniper and Cisco switches cannot be used.

openpbm can work with the native PGM protocol via a raw socket but then
one cannot run multiple processes communicating via different ports
effectively.

The fragmentation of packets and the assembly etc in user space is a pain.
