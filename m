From: Greg KH <gregkh@suse.de>
Subject: Re: [33-stable regression ssb/broadcom]
Date: Mon, 13 Sep 2010 14:01:45 -0700
Message-ID: <20100913210145.GA18969@suse.de>
References: <4C8E6192.2010003@mandriva.org>
 <20100913.122329.39186333.davem@davemloft.net>
 <20100913193647.GD4052@tuxdriver.com>
 <4C8E8AC2.2030201@mandriva.org>
 <4C8E8C73.60306@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "stable@kernel.org" <stable@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	"Larry.Finger@lwfinger.net" <Larry.Finger@lwfinger.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Backlund <tmb@mandriva.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37961 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895Ab0IMVCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 17:02:32 -0400
Content-Disposition: inline
In-Reply-To: <4C8E8C73.60306@mandriva.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 13, 2010 at 11:41:23PM +0300, Thomas Backlund wrote:
> Thomas Backlund skrev 13.9.2010 23:34:
> >John W. Linville skrev 13.9.2010 22:36:
> >>On Mon, Sep 13, 2010 at 12:23:29PM -0700, David Miller wrote:
> >>>From: Thomas Backlund<tmb@mandriva.org>
> >>>Date: Mon, 13 Sep 2010 20:38:26 +0300
> >>>
> >>>>In Mandriva 2010.1 we noticed that 2.6.33.7 broke ssb/Broadcom lan for
> >>>>several users...
> >>>>
> >>>>Issue is tracked at:
> >>>>https://qa.mandriva.com/show_bug.cgi?id=60968
> >>>>
> >>>>Reverting the commit restores a working lan.
> >>>>
> >>>>The offending commit is:
> >>>
> >>>Please always CC: netdev on networking reports, otherwise you are
> >>>very unlikely to get any experts looking into your issue.
> >>
> >>IIRC, there was a bad patch that got sent for the 2.6.33.y series.
> >>I thought it had been reverted or fixed already?
> >>
> >
> >Nope.
> >
> >It got added in 2.6.33.7
> >http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.33.y.git;a=commit;h=6fb037c2ed8378c7ab0c1e00536ba6b2a866503e
> >
> 
> After checking some more...
> 
> I see the revert of the broken patch was done in 2.6.34.3 and a set
> of ssb patches replacing it...
> 
> but it didn't happend for 2.6.33.y

Yeah, I think I "dropped" support for .33 by then and I really didn't
care anymore.

Note, I have gotten a few rumblings that I should bring .33 back to life
for some loving due to a few distros relying on it, but I need to find
the time in my schedule to do so...

thanks,

greg k-h
