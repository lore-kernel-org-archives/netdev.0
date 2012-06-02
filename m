From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: Network hangs on current git kernel
Date: Sat, 2 Jun 2012 18:34:37 +0200
Message-ID: <20120602163437.GA16598@x4>
References: <20120602082503.GC329@x4>
 <1338630610.2760.1695.camel@edumazet-glaptop>
 <20120602105747.GB28769@electric-eye.fr.zoreil.com>
 <1338635703.2760.1696.camel@edumazet-glaptop>
 <20120602112334.GA10145@x4>
 <1338652120.2760.1705.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:54136 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758345Ab2FBQek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 12:34:40 -0400
Content-Disposition: inline
In-Reply-To: <1338652120.2760.1705.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012.06.02 at 17:48 +0200, Eric Dumazet wrote:
> On Sat, 2012-06-02 at 13:23 +0200, Markus Trippelsdorf wrote:
> > On 2012.06.02 at 13:15 +0200, Eric Dumazet wrote:
> > > On Sat, 2012-06-02 at 12:57 +0200, Francois Romieu wrote:
> > > > Eric Dumazet <eric.dumazet@gmail.com> :
> > > > > On Sat, 2012-06-02 at 10:25 +0200, Markus Trippelsdorf wrote:
> > > > [hang]
> > > > > Maybe tell us what NIC it is, that sort of things...
> > > > 
> > > > As well as 'ip -s link' and complete dmesg from boot.
> > > > Kernel .config may be.
> > > 
> > > yes, and "netstat -s" is always useful
> > 
> > It's an ATL1E NIC. The kernel config is attached.
> 
> Driver tx completion is buggy, but it should hang forever...
> 
> If you ping your local gateway, you also have 'hangs' ?

Will keep an eye on that.
After all this could well be just a buggy router, that broke in the last
few days by coincidence...

-- 
Markus
