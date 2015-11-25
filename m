From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v3 3/5] ipaddress: fix ipaddr_flush for Linux >=
 3.1
Date: Wed, 25 Nov 2015 15:32:08 +0100
Message-ID: <20151125143208.GD23115@orbit.nwl.cc>
References: <20151123163115.5f8be482@xeon-e3>
 <1448375464-12145-1-git-send-email-phil@nwl.cc>
 <1448375464-12145-4-git-send-email-phil@nwl.cc>
 <5655B944.8030903@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38076 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbbKYOcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 09:32:10 -0500
Content-Disposition: inline
In-Reply-To: <5655B944.8030903@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Wed, Nov 25, 2015 at 04:36:04PM +0300, Sergei Shtylyov wrote:
> On 11/24/2015 5:31 PM, Phil Sutter wrote:
> 
> > Linux version 3.1 introduced a consistency check for netlink dumps in
> > commit 670dc28 ("netlink: advertise incomplete dumps"). This bites
> 
>     Need 12-digit SHA1 here, scripts/checkpatch.pl checks this now.

Dejavu! [1]

Again, this is luckily just iproute2. But thanks again for the reminder,
I've set 'core.abbrev = 13' now globally on all my machines, that should
hold for a while. :)

Cheers, Phil

[1]: https://www.mail-archive.com/netdev@vger.kernel.org/msg86385.html
