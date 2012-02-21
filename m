From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V3 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 17:46:27 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F9537C@ORSMSX106.amr.corp.intel.com>
References: <20120216235218.6381.51539.stgit@gitlad.jf.intel.com>
 <20120220.005451.548532173290909435.davem@davemloft.net>
 <C5551D9AAB213A418B7FD5E4A6F30A0702F950C8@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64594 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445Ab2BURqq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:46:46 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F950C8@ORSMSX106.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Rose, Gregory V
> Sent: Tuesday, February 21, 2012 8:15 AM
> To: David Miller
> Cc: netdev@vger.kernel.org
> Subject: RE: [RFC V3 PATCH] rtnetlink: Fix problem with buffer allocation
> 
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Sunday, February 19, 2012 9:55 PM
> > To: Rose, Gregory V
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [RFC V3 PATCH] rtnetlink: Fix problem with buffer
> allocation
> >
> > From: Greg Rose <gregory.v.rose@intel.com>
> > Date: Thu, 16 Feb 2012 15:52:18 -0800
> >
> > > +	for (h = 0; h < NETDEV_HASHENTRIES; h++) {
> > > +		head = &net->dev_index_head[h];
> > > +		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {
> >
> > list_for_each_entry_rcu(dev, &net->dev_base_head, dev_list)
> 
> OK, I'll fix that up.

Having seen no other review comments on this RFC or the related iproute2 RFC I'll go ahead and work with Jeff Kirsher to get these patches pushed for application.

- Greg
