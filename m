From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] rtnetlink: make SR-IOV VF interface symmetric
Date: Mon, 17 May 2010 09:55:36 -0700
Message-ID: <20100517095536.1ad6a317@nehalam>
References: <20100515031416.GE15313@sequoia.sous-sol.org>
	<20100517085936.39016980@nehalam>
	<EA929A9653AAE14F841771FB1DE5A1365FF3999206@rrsmsx501.amr.corp.intel.com>
	<20100517160732.GA8301@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"scofeldm@cisco.com" <scofeldm@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35538 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353Ab0EQQzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 12:55:43 -0400
In-Reply-To: <20100517160732.GA8301@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 May 2010 09:07:32 -0700
Chris Wright <chrisw@sous-sol.org> wrote:

> * Williams, Mitch A (mitch.a.williams@intel.com) wrote:
> > >-----Original Message-----
> > >From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > >Sent: Monday, May 17, 2010 9:00 AM
> > >To: Chris Wright
> > >Cc: davem@davemloft.net; kaber@trash.net; Williams, Mitch A;
> > >arnd@arndb.de; scofeldm@cisco.com; netdev@vger.kernel.org
> > >Subject: Re: [PATCH] rtnetlink: make SR-IOV VF interface symmetric
> > >
> > >On Fri, 14 May 2010 20:14:16 -0700
> > >Chris Wright <chrisw@sous-sol.org> wrote:
> > >
> > >> Now we have a set of nested attributes:
> > >>
> > >>   IFLA_VFINFO_LIST (NESTED)
> > >>     IFLA_VF_INFO (NESTED)
> > >>       IFLA_VF_MAC
> > >>       IFLA_VF_VLAN
> > >>       IFLA_VF_TX_RATE
> > >>
> > >> This allows a single set to operate on multiple attributes if desired.
> > >> Among other things, it means a dump can be replayed to set state.
> > >>
> > >> The current interface has yet to be released, so this seems like
> > >> something to consider for 2.6.34.
> > >>
> > >> Signed-off-by: Chris Wright <chrisw@sous-sol.org
> > >> ---
> > >
> > >iproute2 update please?
> > >
> > >Also I would really like documentation on this.
> 
> And a pony? ;-)
> 
> Docs in what form?
> 

The man page for ip.8 already has some pieces from other version.
Just fix them.  I just pushed up a couple of changes.

-- 
