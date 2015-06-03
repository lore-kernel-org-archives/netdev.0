From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Wed, 3 Jun 2015 16:11:56 -0400
Message-ID: <20150603201156.GM588@gospo.home.greyhouse.net>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bD6eZGR2k-CMUhCrYhpH7sgCHCaAZ=7u1ot1j4TQGPVgA@mail.gmail.com>
 <20150603182718.GK588@gospo.home.greyhouse.net>
 <CAE4R7bDLgHYzWC=m-R73psbyLwZh0fvL_diFyW3g1DF8eve1sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36595 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263AbbFCUL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 16:11:59 -0400
Received: by qkx62 with SMTP id 62so12413494qkx.3
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 13:11:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bDLgHYzWC=m-R73psbyLwZh0fvL_diFyW3g1DF8eve1sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 12:03:53PM -0700, Scott Feldman wrote:
> On Wed, Jun 3, 2015 at 11:27 AM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > On Wed, Jun 03, 2015 at 11:15:55AM -0700, Scott Feldman wrote:
> >> On Tue, Jun 2, 2015 at 8:07 PM, Andy Gospodarek
> >> <gospo@cumulusnetworks.com> wrote:
> >> > This feature is only enabled with the new sysctl set (default is off):
> >> > net.core.kill_routes_on_linkdown = 1
> >>
> >> One more thing, sorry.  This feature is typically implemented today in
> >> user-space on a per-interface basis.  The example I'm thinking of is
> >> Quagga's "link-detect" directive which goes on an interface.  Should
> >> this be a bool on each interface in systcl?  That would let user not
> >> enable on selected interfaces.
> > That would not be my preference.
> >
> > I'm willing to investigate the per-namespace support if Hannes would
> > like and add switchdev support for v2, but would prefer this not become
> > that granular.
> 
> 
> Is there a reason?  Seems you moving a feature from user space to the
> kernel, so I'm curious why you wouldn't want to mimic functionality
> that's available today.
To me it seemed like a feature that is more globally useful so I wanted
to just have it that way to start.  I'm not opposed to per-device
granularity in the future, but I did not want to differentiate right out
of the gate when there are enough other moving parts.

> I like the patch/feature, BTW.  Thanks for doing this.
Glad to hear it!  :)
