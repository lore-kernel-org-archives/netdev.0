From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V3 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 16:15:02 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F950C8@ORSMSX106.amr.corp.intel.com>
References: <20120216235218.6381.51539.stgit@gitlad.jf.intel.com>
 <20120220.005451.548532173290909435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab2BUQPE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 11:15:04 -0500
In-Reply-To: <20120220.005451.548532173290909435.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, February 19, 2012 9:55 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC V3 PATCH] rtnetlink: Fix problem with buffer allocation
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Thu, 16 Feb 2012 15:52:18 -0800
> 
> > +	for (h = 0; h < NETDEV_HASHENTRIES; h++) {
> > +		head = &net->dev_index_head[h];
> > +		hlist_for_each_entry_rcu(dev, node, head, index_hlist) {
> 
> list_for_each_entry_rcu(dev, &net->dev_base_head, dev_list)

OK, I'll fix that up.

- Greg
