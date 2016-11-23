From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH v3] net: dummy: Introduce dummy virtual functions
Date: Wed, 23 Nov 2016 17:24:30 +0100
Message-ID: <20161123162430.GD6158@orbyte.nwl.cc>
References: <20161123124125.3374-1-phil@nwl.cc>
 <1479907588.8455.484.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Sabrina Dubroca <sd@queasysnail.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57337 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755665AbcKWQYu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 11:24:50 -0500
Content-Disposition: inline
In-Reply-To: <1479907588.8455.484.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 05:26:28AM -0800, Eric Dumazet wrote:
> On Wed, 2016-11-23 at 13:41 +0100, Phil Sutter wrote:
> 
> > +struct vf_data_storage {
> > +	unsigned char vf_mac[ETH_ALEN];
> > +	u16 pf_vlan; /* When set, guest VLAN config not allowed. */
> > +	u16 pf_qos;
> > +	__be16 vlan_proto;
> > +	u16 min_tx_rate;
> > +	u16 max_tx_rate;
> > +	u8 spoofchk_enabled;
> > +	bool rss_query_enabled;
> > +	u8 trusted;
> > +	int link_state;
> > +};
> 
> Could you use proper indentation of field names ?

Sure!

> struct vf_data_storage {
> 	u8	vf_mac[ETH_ALEN];

Also thanks for suggesting u8 here. I really shouldn't copy'n'paste
code, not even from a well-maintained driver.

Thanks, Phil
