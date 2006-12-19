From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 7708] New: unregister_netdev() should return
 unregister_netdevice() return code
Date: Mon, 18 Dec 2006 17:37:45 -0800 (PST)
Message-ID: <20061218.173745.08333482.davem@davemloft.net>
References: <200612182256.kBIMuVio025766@fire-2.osdl.org>
	<20061218152111.868f9284.akpm@osdl.org>
	<20061218155057.1904f666@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, benjamin.li@qlogic.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49454
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932635AbWLSBiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 20:38:12 -0500
To: shemminger@osdl.org
In-Reply-To: <20061218155057.1904f666@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 18 Dec 2006 15:50:57 -0800

> On Mon, 18 Dec 2006 15:21:11 -0800
> Andrew Morton <akpm@osdl.org> wrote:
> 
> > > net/core/dev.c:unregister_netdev() function is a wrapper around
> > > net/core/dev.c:unregister_netdevice().  The unregister_netdevice() function
> > > returns a return code while unregister_netdev() currently does not.  For
> > > completeness, we should pass the return code from unregister_netdevice() all the
> > > way to the caller.  unregister_netdev() should not swallow the return code.
> > > 
> > 
> > Certainly there's some truth in that ;)
> > 
> > Is there some reason why you want to test the unregister_netdev() return
> > value?
> The only return value is -ENODEV, so I would vote for both just being void

Me too.

FWIW, I think bug reports like this are a lot of back-and-forth waste
of time.  If it's important enough to someone, let them write a
god-damn patch for something so amazingly trivial.  With the bugzill
entry, you have to respond to it, change it's diapers, etc.
