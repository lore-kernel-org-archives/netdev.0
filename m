From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [ovs-dev] [PATCH net-next v9] openvswitch: enable NSH support
Date: Wed, 27 Sep 2017 09:09:07 +0800
Message-ID: <20170927010906.GB97665@cran64.bj.intel.com>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
 <20170925192842.GD1786@dev-rhel7>
 <20170926050215.GB5896@localhost.localdomain>
 <20170926205936.GE1786@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:39356 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968827AbdI0BYV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 21:24:21 -0400
Content-Disposition: inline
In-Reply-To: <20170926205936.GE1786@dev-rhel7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 04:59:36AM +0800, Eric Garver wrote:
> On Tue, Sep 26, 2017 at 01:02:15PM +0800, Yang, Yi wrote:
> > On Tue, Sep 26, 2017 at 03:28:42AM +0800, Eric Garver wrote:
> > > On Mon, Sep 25, 2017 at 10:16:09PM +0800, Yi Yang wrote:
> > > > +
> > > > +	length = nsh_hdr_len(nsh_hdr);
> > > > +	skb_pull(skb, length);
> > > 
> > > Do you need to verify you can actually pull length bytes? I don't see
> > > any guarantee.
> > 
> > I have added skb length check in pop_nsh, so that can verify this.
> 
> That doesn't help other code that may call skb_pop_nsh(). skb_vlan_pop()
> calls skb_ensure_writable() which seems like the right thing to do.

Make sense, I will move it to skp_pop_nsh, thanks.
