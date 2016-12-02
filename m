From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next v3 11/12] mlxsw: spectrum_router: Request a dump
 of FIB tables during init
Date: Fri, 2 Dec 2016 11:34:29 +0200
Message-ID: <20161202093429.vo3cehjwxu5b2zpx@splinter>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
 <1480500546-2544-12-git-send-email-jiri@resnulli.us>
 <eb7ddecd-d6b4-dfce-5990-9e933227c862@stressinduktion.org>
 <20161130163229.rkxvuwukgg35ktrx@splinter.mtl.com>
 <043a2ba9-1e19-c3cd-a930-59e8cb0d5f7a@stressinduktion.org>
 <20161130182243.cpoyoqvxuv2bnn4y@splinter.mtl.com>
 <ea2a8856-59d8-1b5f-9428-b16efa8f6979@stressinduktion.org>
 <20161201231445.vtx7mjxuxusar3mu@splinter>
 <75d6f272-9320-8aed-4de2-3f69d9b3ea3c@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45439 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751573AbcLBJed (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 04:34:33 -0500
Content-Disposition: inline
In-Reply-To: <75d6f272-9320-8aed-4de2-3f69d9b3ea3c@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 12:27:25AM +0100, Hannes Frederic Sowa wrote:
> I really like that. Would you mind adding this?

Yes. I'll send another version to Jiri today after testing and hopefully
we can submit today / tomorrow. I think Linus is still undecided about
-rc8 and I would like to get this in 4.10.

> >> Quick follow-up question: How can I quickly find out the hw limitations
> >> via the kernel api?
> > 
> > That's a good question. Currently, you can't. However, we already have a
> > mechanism in place to read device's capabilities from the firmware and
> > we can (and should) expose some of them to the user. The best API for
> > that would be devlink, as it can represent the entire device as opposed
> > to only a port netdev like other tools.
> > 
> > We're also working on making the pipeline more visible to the user, so
> > that it would be easier for users to understand and debug their
> > networks. I believe a colleague of mine (Matty) presented this during
> > the last netdev conference.
> 
> Thanks, I will look it up!

Found it:
https://www.youtube.com/watch?v=gwzaKXWIelc&feature=youtu.be&list=PLrninrcyMo3IkTvpvM2LK6gn4NdbFhI0G&t=6892
