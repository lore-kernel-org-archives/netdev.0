From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Thu, 13 Feb 2014 17:00:21 -0500
Message-ID: <20140213220021.GA1174@redhat.com>
References: <20140212205122.5783660e@nehalam.linuxnetplumber.net>
 <1392273125.2214.25.camel@joe-AO722>
 <alpine.DEB.2.02.1402132252290.1967@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218AbaBMWAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 17:00:38 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402132252290.1967@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 13, 2014 at 10:55:23PM +0100, Julia Lawall wrote:

 > The patch below converts label: return; } to label: ; }.  I have only 
 > scanned through the patches, not patched the code and looked at the 
 > results, so I am not sure that it is completely correct.  On the other 
 > hand, I'm also not sure that label: ; } is better than label: return; }, 
 > either.  If people think it is, then I can cheack the results in more 
 > detail.

Why not delete the label, and just replace the goto with a return if
the label is at the end of the function ?

	Dave
