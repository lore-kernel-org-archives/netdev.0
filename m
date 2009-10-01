From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/2] cfg80211: firmware and hardware version
Date: Thu, 1 Oct 2009 13:07:22 -0400
Message-ID: <20091001170722.GC2895@tuxdriver.com>
References: <20090924180048.14503.9579.stgit@tikku> <43e72e890909241320j592e347die8a14f8bdd962ffb@mail.gmail.com> <20090925044258.GA2722@tuxdriver.com> <da94abde0909250947k5084db85vccafe0d3e74e2ecf@mail.gmail.com> <43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com> <20091001011340.GA3123@tuxdriver.com> <87fxa3qjt2.fsf@purkki.valot.fi> <20091001151820.GA2895@tuxdriver.com> <873a63qe6e.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kalle.valo@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36891 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755843AbZJARP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 13:15:56 -0400
Content-Disposition: inline
In-Reply-To: <873a63qe6e.fsf@purkki.valot.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 01, 2009 at 07:20:09PM +0300, Kalle Valo wrote:
> "John W. Linville" <linville@tuxdriver.com> writes:
> 
> > On Thu, Oct 01, 2009 at 05:18:33PM +0300, Kalle Valo wrote:

> > Anyway, adding a couple of ioctl calls isn't a big deal.
> 
> Sure, but we need to support this forever. If, say after two years, we
> decide that ethtool is not the way to go, it's very difficult to
> remove it. The less interfaces we have, the easier it is to maintain
> them.

Just to be clear, I was taling about adding ioctl calls to a
userland application (if you didn't want to use the ethtool utility).
The required ioctls are already defined for ethtool in the kernel.

> >>         ethtool -r|--negotiate DEVNAME  Restart N-WAY negotation
> >
> > Ethernet-specific...might could be overloaded for wireless to trigger
> > reassoc...?
> 
> Please no, I don't want to see any reassociation or anything else
> 802.11 state related in ethtool, nl80211 was created for this. This is
> something I would object loudly :)

Well, it was just a thought... :-)

> > Anyway, between the link detection and making distro scripts work
> > plus enabling a familiar tool for basic driver info I think this is
> > a win.  So much the better if some drivers move to ethtool for register
> > dumping, setting message verbosity, querying/changing eeprom values,
> > etc, etc...
> 
> Sounds good enough. As I said in my earlier email, I'm not going argue
> about this for too long. You know this better than I do. So let's go
> forward with ethtool. 
> 
> Thanks for listening to my concerns.

Sure, np.  And FWIW, I don't predict a huge problem if there are
valid extensions required for use by wireless drivers in the future.
But for now, I'd like to see us make use of some of the debugging
facilities available in the ethtool API -- hopefully the iwlwifi guys
are listening... ;-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
