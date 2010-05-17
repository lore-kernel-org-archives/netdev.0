From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] rtnetlink: make SR-IOV VF interface symmetric
Date: Mon, 17 May 2010 09:07:32 -0700
Message-ID: <20100517160732.GA8301@sequoia.sous-sol.org>
References: <20100515031416.GE15313@sequoia.sous-sol.org>
 <20100517085936.39016980@nehalam>
 <EA929A9653AAE14F841771FB1DE5A1365FF3999206@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Chris Wright <chrisw@sous-sol.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"scofeldm@cisco.com" <scofeldm@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:41283 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751683Ab0EQQHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 12:07:48 -0400
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FF3999206@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Williams, Mitch A (mitch.a.williams@intel.com) wrote:
> >-----Original Message-----
> >From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> >Sent: Monday, May 17, 2010 9:00 AM
> >To: Chris Wright
> >Cc: davem@davemloft.net; kaber@trash.net; Williams, Mitch A;
> >arnd@arndb.de; scofeldm@cisco.com; netdev@vger.kernel.org
> >Subject: Re: [PATCH] rtnetlink: make SR-IOV VF interface symmetric
> >
> >On Fri, 14 May 2010 20:14:16 -0700
> >Chris Wright <chrisw@sous-sol.org> wrote:
> >
> >> Now we have a set of nested attributes:
> >>
> >>   IFLA_VFINFO_LIST (NESTED)
> >>     IFLA_VF_INFO (NESTED)
> >>       IFLA_VF_MAC
> >>       IFLA_VF_VLAN
> >>       IFLA_VF_TX_RATE
> >>
> >> This allows a single set to operate on multiple attributes if desired.
> >> Among other things, it means a dump can be replayed to set state.
> >>
> >> The current interface has yet to be released, so this seems like
> >> something to consider for 2.6.34.
> >>
> >> Signed-off-by: Chris Wright <chrisw@sous-sol.org
> >> ---
> >
> >iproute2 update please?
> >
> >Also I would really like documentation on this.

And a pony? ;-)

Docs in what form?

> Chris, have you got the iproute2 parts working, or do I need to pick it up?
> 
> Thanks again for your work on this.

I've got those bits, just was waiting until patches merged.
Will send them out this afternoon.

thanks,
-chris
