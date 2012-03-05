From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] bridge: Adjust min age inc for HZ > 256
Date: Mon, 5 Mar 2012 13:30:00 -0800
Message-ID: <20120305133000.72206a30@nehalam.linuxnetplumber.net>
References: <20120304210350.629ec5c6@nehalam.linuxnetplumber.net>
	<20120305.000921.1233132850153467742.davem@davemloft.net>
	<OF2C9B7723.897FDDA7-ONC12579B8.002D1A5A-C12579B8.002D3A31@transmode.se>
	<20120305.032410.1729877140582678194.davem@davemloft.net>
	<OF88775C78.CE313829-ONC12579B8.003017A8-C12579B8.003053F0@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35720 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687Ab2CEVaD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 16:30:03 -0500
In-Reply-To: <OF88775C78.CE313829-ONC12579B8.003017A8-C12579B8.003053F0@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Mar 2012 09:47:52 +0100
Joakim Tjernlund <joakim.tjernlund@transmode.se> wrote:

> David Miller <davem@davemloft.net> wrote on 2012/03/05 09:24:10:
> >
> > From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> > Date: Mon, 5 Mar 2012 09:14:00 +0100
> >
> > > David Miller <davem@davemloft.net> wrote on 2012/03/05 06:09:21:
> > >>
> > >> From: Stephen Hemminger <shemminger@vyatta.com>
> > >> Date: Sun, 4 Mar 2012 21:03:50 -0800
> > >>
> > >> > I don't understand why this is required.
> > >>
> > >> And I don't understand why it takes nearly a week to review a one line
> > >> patch like this.
> > >>
> > >> If you don't say anything I'm going to just apply it after a few days,
> > >> which is what I did here already.
> > >>
> > >> Me applying it should never be your trigger to review the patch, yet I
> > >> see this happen all the time.  What do you think I was waiting for
> > >> these past 5 days, divine intervention?
> > >
> > > hmm, does this mean you "unapplied" the patch now?
> >
> > I can't, it's now in the permanent record so I can't remove it.
> >
> > At best I can apply a revert patch, but you guys are still discussing
> > this so I have no idea whether that's even necessary or not.
> 
> OK, hopefully Stephen is happy with my explanation. In any case
> I won't be able to retest if only patch 2 is needed as our test window closed
> this weekend.
> 
>  Jocke
> 

I am okay with the change, but that whole section needs more comments
and explanation. 
