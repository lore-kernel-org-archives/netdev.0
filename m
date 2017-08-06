From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net 3/3] tcp: fix xmit timer to only be reset if data
 ACKed/SACKed
Date: Sun, 6 Aug 2017 09:44:35 +0200
Message-ID: <20170806074435.GA13300@1wt.eu>
References: <20170801025814.31206-1-ncardwell@google.com>
 <20170801025814.31206-4-ncardwell@google.com>
 <F95AC9340317A84688A5F0DF0246F3F2029373BA@DGGEMI512-MBX.china.huawei.com>
 <CADVnQykAKkb7KDhM03HHOHk8Uk7rMfXcyaLsHMLZRVT_g69euA@mail.gmail.com>
 <20170804171000.GB5342@1wt.eu>
 <CADVnQymnVwT30EzVvTfZ0EX_6ehRom1W8Yt2Z5SQHhmWO+e+sw@mail.gmail.com>
 <20170804181854.GA5478@1wt.eu>
 <F95AC9340317A84688A5F0DF0246F3F202940EA5@DGGEMI512-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neal Cardwell <ncardwell@google.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:35101 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751258AbdHFHoq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 6 Aug 2017 03:44:46 -0400
Content-Disposition: inline
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F202940EA5@DGGEMI512-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 06, 2017 at 07:39:57AM +0000, maowenan wrote:
> 
> 
> > -----Original Message-----
> > From: Willy Tarreau [mailto:w@1wt.eu]
> > Sent: Saturday, August 05, 2017 2:19 AM
> > To: Neal Cardwell
> > Cc: maowenan; David Miller; netdev@vger.kernel.org; Yuchung Cheng; Nandita
> > Dukkipati; Eric Dumazet
> > Subject: Re: [PATCH net 3/3] tcp: fix xmit timer to only be reset if data
> > ACKed/SACKed
> > 
> > On Fri, Aug 04, 2017 at 02:01:34PM -0400, Neal Cardwell wrote:
> > > On Fri, Aug 4, 2017 at 1:10 PM, Willy Tarreau <w@1wt.eu> wrote:
> > > > Hi Neal,
> > > >
> > > > On Fri, Aug 04, 2017 at 12:59:51PM -0400, Neal Cardwell wrote:
> > > >> I have attached patches for this fix rebased on to v3.10.107, the
> > > >> latest stable release for 3.10. That's pretty far back in history,
> > > >> so there were substantial conflict resolutions and adjustments required.
> > > >> :-) Hope that helps.
> > > >
> > > > At least it will help me :-)
> > > >
> > > > Do you suggest that I queue them for 3.10.108, that I wait for
> > > > Maowenan to test them more broadly first or anything else ?
> > >
> > > Let's wait for Maowenan to test them first.
> [Mao Wenan]It works well with these patches of v3.10, and the 
> retransmission packet is about 250ms after TLP probe.
> Thank you very much for these patches under 3.10.

Thanks, I'll take them then.

Willy
