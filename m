From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Wed, 3 Jun 2015 16:34:07 -0400
Message-ID: <20150603203406.GN588@gospo.home.greyhouse.net>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bD6eZGR2k-CMUhCrYhpH7sgCHCaAZ=7u1ot1j4TQGPVgA@mail.gmail.com>
 <20150603182718.GK588@gospo.home.greyhouse.net>
 <1433361846.719897.286115305.0CA7D2AA@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:34261 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbbFCUeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 16:34:10 -0400
Received: by qcej9 with SMTP id j9so9601821qce.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 13:34:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433361846.719897.286115305.0CA7D2AA@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 10:04:06PM +0200, Hannes Frederic Sowa wrote:
> On Wed, Jun 3, 2015, at 20:27, Andy Gospodarek wrote:
> > On Wed, Jun 03, 2015 at 11:15:55AM -0700, Scott Feldman wrote:
> > > On Tue, Jun 2, 2015 at 8:07 PM, Andy Gospodarek
> > > <gospo@cumulusnetworks.com> wrote:
> > > > This feature is only enabled with the new sysctl set (default is off):
> > > > net.core.kill_routes_on_linkdown = 1
> > > 
> > > One more thing, sorry.  This feature is typically implemented today in
> > > user-space on a per-interface basis.  The example I'm thinking of is
> > > Quagga's "link-detect" directive which goes on an interface.  Should
> > > this be a bool on each interface in systcl?  That would let user not
> > > enable on selected interfaces.
> > That would not be my preference.
> > 
> > I'm willing to investigate the per-namespace support if Hannes would
> > like and add switchdev support for v2, but would prefer this not become
> > that granular.
> 
> Actually, this idea also came to my mind: flagging specific routes if
> they are eligible to suppress if the link is down.
I'll have to think about how this would integrate with the alternative
design suggestion earlier in the thread from Alex.

Even if I do not implement this right away it might be nice to add the
ability to mark routes as permanent if the user desired.
