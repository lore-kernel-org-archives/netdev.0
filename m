From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: bookkeep number of queues
 in our own module
Date: Wed, 18 Jun 2014 15:49:15 +0100
Message-ID: <20140618144914.GH20819@zion.uk.xensource.com>
References: <1403100558-12866-1-git-send-email-wei.liu2@citrix.com>
 <53A19FCA.1090205@oracle.com>
 <20140618142152.GC20819@zion.uk.xensource.com>
 <107856333.20140618163447@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>, David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:35062 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbaFROtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 10:49:16 -0400
Content-Disposition: inline
In-Reply-To: <107856333.20140618163447@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2014 at 04:34:47PM +0200, Sander Eikelenboom wrote:
[...]
> >> David sent a couple of patches earlier today that I have been testing and
> >> they appear to fix both netfront and netback. (I am waiting for 32-bit to
> >> finish)
> >> 
> >> http://lists.xenproject.org/archives/html/xen-devel/2014-06/msg02308.html
> >> 
> 
> > I saw that, but they don't fix this backend bug. Try crashing the guest
> > before it connects to backend. As I said in commit message:
> 
> Hmm i guess that was the bug_on i hit some time ago with testing the multiqueue 
> patches, from what i remember i indeed had guest that crashed earlier on.
> 

Probably. The oops message in your report looked very much alike. Just
that I didn't have convenient mean to reproduce so I couldn't fix it
earlier. :-)

Wei.
