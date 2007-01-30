From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 problems on Intel Mac Mini
Date: Tue, 30 Jan 2007 15:21:50 -0800
Message-ID: <20070130152150.01955639@freekitty>
References: <DJgDe2E/Cvnb.CrmE6+LDxkzqNQTYvzH+WQ@sphinx.mythic-beasts.com>
	<20070129160117.7dda9563@freekitty>
	<LF3DwQ8KEqWr.IS8NEpV+rQSn3zksVUhTmQ@sphinx.mythic-beasts.com>
	<20070130094033.GA11674@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Lightfoot <chris@ex-parrot.com>, netdev@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56191 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbXA3XYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 18:24:36 -0500
In-Reply-To: <20070130094033.GA11674@dose.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Jan 2007 10:40:33 +0100
Tino Keitel <tino.keitel@tikei.de> wrote:

> On Tue, Jan 30, 2007 at 08:39:19 +0000, Chris Lightfoot wrote:
> > On Mon, Jan 29, 2007 at 04:01:17PM -0800, Stephen Hemminger wrote:
> > > On Mon, 29 Jan 2007 23:57:32 +0000
> > > Chris Lightfoot <chris@ex-parrot.com> wrote:
> > > 
> > > >   [ please cc: me on any reply ]
> > > > 
> > > > I'm seeing lots of problems with the sky2 driver on Mac
> > > > Minis. Based on the suggestions in,
> > > >     http://www.mail-archive.com/netdev@vger.kernel.org/msg28221.html
> > > > I am running stock 2.6.19 + the patches from the
> > > > mactel-linux.org site to get the kernel booting on the
> > > > Apple hardware; none of these touches the sky2 code. The
> > > > module is installed with disable_msi=1 and
> > > > idle_timeout=10; the chip version is,
> > > >     Yukon-EC (0xb6) rev 2
> > > > 
> > > > The crashes we're seeing at the moment show (with
> > > > debug=16) lots and lots of transmits being queued up and
> > > > never being completed, even with the timeout switched on.
> > > > For instance, (this is on a machine running NFS root and
> > > > vlans)
> > > 
> > > Is this NFS over UDP?
> > 
> > yes. but we see similar problems on machines which aren't
> > doing lots of UDP traffic.
> 
> Hi,
> 
> I found my machine with a freezed desktop tomorrow morning. I don't use
> anything UDP specific, just a lot of TCP traffic. I the machine is a
> Mac mini Core Duo running 2.6.20-rc6 without special mactel-linux.org
> patches except for the IR remote driver. The kernel log looks similar.
> I don't use MSI. However, I don't get this several times a day. IIRC
> this was the first time that I saw this.
> 
> Regards,
> Tino

Are you running 64 bit (x86-64) or 32 bit (i386)?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
