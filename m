From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] net: ppp_generic - fix broken userspace
Date: Sun, 11 Jan 2009 14:45:53 +0300
Message-ID: <20090111114553.GA19261@localhost>
References: <20090110202802.GF29349@localhost> <20090110203112.GG29349@localhost> <18793.15831.279207.252421@cargo.ozlabs.ibm.com> <20090110.233503.222465267.davem@davemloft.net> <18793.51741.28374.460500@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	jchapman@katalix.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:34138 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbZAKLp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 06:45:56 -0500
Content-Disposition: inline
In-Reply-To: <18793.51741.28374.460500@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Paul Mackerras - Sun, Jan 11, 2009 at 09:29:49PM +1100]
| David Miller writes:
| 
| > PPP was converted to use IDR instead of PPP's duplicate
| > implementation.
| > 
| > A bug was introduced in that conversion, and that bug is being fixed
| > here.
| > 
| > What is not to like? :-)
| 
| Ah OK, that sounds all right.  I was reacting to the "broken
| userspace" in the patch description which at first glance seemed to be
| saying that userspace (i.e. pppd :) is doing something which has
| recently been declared to be wrong and therefore it is "broken".
| 
| I think "fix broken userspace" as a patch headline is quite
| ambiguous.  Something like "Fix bug in conversion to use IDR" would be
| more informative.
| 
| Paul.
| 

David, if you pick this patch could you rename
the subject then as Paul proposed? Or I should
resend the patch with new title?

To Paul: my bad, sorry. I thought like -- I broke
user-space pppd so it's broken now and lets fix
it -- here is "fix broken userspace" grown from :)

		- Cyrill -
