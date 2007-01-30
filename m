From: Chris Lightfoot <chris@ex-parrot.com>
Subject: Re: sky2 problems on Intel Mac Mini
Date: Tue, 30 Jan 2007 08:39:19 +0000
Message-ID: <LF3DwQ8KEqWr.IS8NEpV+rQSn3zksVUhTmQ@sphinx.mythic-beasts.com>
References: <DJgDe2E/Cvnb.CrmE6+LDxkzqNQTYvzH+WQ@sphinx.mythic-beasts.com> <20070129160117.7dda9563@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wumpus2.mythic-beasts.com ([212.69.38.51]:60711 "EHLO
	wumpus2.mythic-beasts.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbXA3IjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 03:39:21 -0500
Content-Disposition: inline
In-Reply-To: <20070129160117.7dda9563@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 04:01:17PM -0800, Stephen Hemminger wrote:
> On Mon, 29 Jan 2007 23:57:32 +0000
> Chris Lightfoot <chris@ex-parrot.com> wrote:
> 
> >   [ please cc: me on any reply ]
> > 
> > I'm seeing lots of problems with the sky2 driver on Mac
> > Minis. Based on the suggestions in,
> >     http://www.mail-archive.com/netdev@vger.kernel.org/msg28221.html
> > I am running stock 2.6.19 + the patches from the
> > mactel-linux.org site to get the kernel booting on the
> > Apple hardware; none of these touches the sky2 code. The
> > module is installed with disable_msi=1 and
> > idle_timeout=10; the chip version is,
> >     Yukon-EC (0xb6) rev 2
> > 
> > The crashes we're seeing at the moment show (with
> > debug=16) lots and lots of transmits being queued up and
> > never being completed, even with the timeout switched on.
> > For instance, (this is on a machine running NFS root and
> > vlans)
> 
> Is this NFS over UDP?

yes. but we see similar problems on machines which aren't
doing lots of UDP traffic.

-- 
          Man: How was your flight, sir?
Prince Philip: Have you ever been on an aeroplane?
          Man: Yes.
Prince Philip: Well, it was like that.
