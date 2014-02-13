From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Thu, 13 Feb 2014 23:06:55 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1402132306020.1967@localhost6.localdomain6>
References: <20140212205122.5783660e@nehalam.linuxnetplumber.net> <1392273125.2214.25.camel@joe-AO722> <alpine.DEB.2.02.1402132252290.1967@localhost6.localdomain6> <20140213220021.GA1174@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:41366
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750932AbaBMWHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:07:04 -0500
In-Reply-To: <20140213220021.GA1174@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Feb 2014, Dave Jones wrote:

> On Thu, Feb 13, 2014 at 10:55:23PM +0100, Julia Lawall wrote:
> 
>  > The patch below converts label: return; } to label: ; }.  I have only 
>  > scanned through the patches, not patched the code and looked at the 
>  > results, so I am not sure that it is completely correct.  On the other 
>  > hand, I'm also not sure that label: ; } is better than label: return; }, 
>  > either.  If people think it is, then I can cheack the results in more 
>  > detail.
> 
> Why not delete the label, and just replace the goto with a return if
> the label is at the end of the function ?

Good point :)

julia
