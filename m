From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Wed, 4 Nov 2015 14:26:14 -0500
Message-ID: <20151104192614.GC14575@oracle.com>
References: <20151030183645.GD32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
 <20151030192437.GE32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACC2E@fmsmsx115.amr.corp.intel.com>
 <20151030231301.GA14974@oracle.com>
 <20151101162407.GA26373@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFAD1C9@fmsmsx115.amr.corp.intel.com>
 <20151102000701.GD9552@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFAD398@fmsmsx115.amr.corp.intel.com>
 <20151102195707.GC15009@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38048 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756412AbbKDT0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 14:26:18 -0500
Content-Disposition: inline
In-Reply-To: <20151102195707.GC15009@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/02/15 14:57), Sowmini Varadhan wrote:
> On (11/02/15 17:26), Nelson, Shannon wrote:
> > > I assume you mean .1q 
> > 
> > Yes, this is what I had in mind.
> 
> I dont think we're quite there yet, even without vlans.
> 

Ok finally got all the .1q stuff verified (took a bit longer
than it should, because of some lab/administrative hassles in
getting the vlans adjusted at intermediate switches). But
the fix as I'd sent has been tested, and it is good for .1q.

The issues I was seeing with promisc were orthogonal to my fix,
or even to my platform - I understand those are being addressed
separately.

I'm probably too late for the merge window, and I dont know if
this fix qualifies as "critical" for net, so I'll re-target v5 
for net-next, to be conservative.

--Sowmini
