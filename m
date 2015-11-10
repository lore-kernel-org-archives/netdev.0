From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 4/6] ipaddress: fix ipaddr_flush for Linux >=
 3.1
Date: Tue, 10 Nov 2015 12:21:30 +0100
Message-ID: <20151110112130.GN26876@orbit.nwl.cc>
References: <1447010471-559-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-5-git-send-email-phil@nwl.cc>
 <5640EB36.306@cogentembedded.com>
 <5640ECEA.8020808@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:58586 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245AbbKJLVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2015 06:21:32 -0500
Content-Disposition: inline
In-Reply-To: <5640ECEA.8020808@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2015 at 09:58:50PM +0300, Sergei Shtylyov wrote:
> On 11/09/2015 09:51 PM, Sergei Shtylyov wrote:
> 
> >> Linux version 3.1 introduced a consistency check for netlink dumps in
> >> commit 670dc28 ("netlink: advertise incomplete dumps"). This bites
> >
> >     The scripts/checkpatch.pl now enforces 12-digit commit ID...
> 
>     Sorry, didn't realize it wasn't a kernel patch. :-)

Heh, no problem! If more projects used checkpatch.pl, the world would be
a better place.

My quoting commits was usually a matter of copying what 'git --oneline
show' outputs. Thanks for the heads-up, I've adjusted core.abbrev now.

Cheers, Phil
