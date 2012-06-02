From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network hangs on current git kernel
Date: Sat, 02 Jun 2012 17:48:40 +0200
Message-ID: <1338652120.2760.1705.camel@edumazet-glaptop>
References: <20120602082503.GC329@x4>
	 <1338630610.2760.1695.camel@edumazet-glaptop>
	 <20120602105747.GB28769@electric-eye.fr.zoreil.com>
	 <1338635703.2760.1696.camel@edumazet-glaptop>  <20120602112334.GA10145@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34497 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758119Ab2FBPsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 11:48:46 -0400
Received: by weyu7 with SMTP id u7so1983076wey.19
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2012 08:48:44 -0700 (PDT)
In-Reply-To: <20120602112334.GA10145@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-02 at 13:23 +0200, Markus Trippelsdorf wrote:
> On 2012.06.02 at 13:15 +0200, Eric Dumazet wrote:
> > On Sat, 2012-06-02 at 12:57 +0200, Francois Romieu wrote:
> > > Eric Dumazet <eric.dumazet@gmail.com> :
> > > > On Sat, 2012-06-02 at 10:25 +0200, Markus Trippelsdorf wrote:
> > > [hang]
> > > > Maybe tell us what NIC it is, that sort of things...
> > > 
> > > As well as 'ip -s link' and complete dmesg from boot.
> > > Kernel .config may be.
> > 
> > yes, and "netstat -s" is always useful
> 
> It's an ATL1E NIC. The kernel config is attached.

Driver tx completion is buggy, but it should hang forever...

If you ping your local gateway, you also have 'hangs' ?
