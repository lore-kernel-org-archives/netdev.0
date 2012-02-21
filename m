From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 21:56:14 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F96E22@ORSMSX106.amr.corp.intel.com>
References: <20120221204715.22575.21711.stgit@gitlad.jf.intel.com>
	<1329860896.18384.61.camel@edumazet-laptop>
 <20120221.165013.133683072829070307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37181 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752249Ab2BUV41 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:56:27 -0500
In-Reply-To: <20120221.165013.133683072829070307.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 21, 2012 1:50 PM
> To: eric.dumazet@gmail.com
> Cc: Rose, Gregory V; netdev@vger.kernel.org
> Subject: Re: [PATCH] rtnetlink: Fix problem with buffer allocation
> 
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 21 Feb 2012 22:48:16 +0100
> 
> > Thats going to hurt some setups (thousand of devices on a server).
> 
> This logic only triggers when the VF attribute is explicitly asked
> for.
> 
> > Also why are you using _rcu() variant here, we hold rtnl I presume ?
> 
> Because that's what I told him to use probably :-)  Indeed, I think
> we can use the non-RCU variant in this spot.

In rtnl_fill_ifinfo the code there uses hlist_for_each_entry_rcu() so I think that's why it got carried over here.  I can remove it.

- Greg
