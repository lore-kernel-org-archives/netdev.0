From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] net: ppp_generic - fix broken userspace
Date: Sun, 11 Jan 2009 21:29:49 +1100
Message-ID: <18793.51741.28374.460500@cargo.ozlabs.ibm.com>
References: <20090110202802.GF29349@localhost>
	<20090110203112.GG29349@localhost>
	<18793.15831.279207.252421@cargo.ozlabs.ibm.com>
	<20090110.233503.222465267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, akpm@linux-foundation.org,
	jchapman@katalix.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47049 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbZAKLdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 06:33:10 -0500
In-Reply-To: <20090110.233503.222465267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller writes:

> PPP was converted to use IDR instead of PPP's duplicate
> implementation.
> 
> A bug was introduced in that conversion, and that bug is being fixed
> here.
> 
> What is not to like? :-)

Ah OK, that sounds all right.  I was reacting to the "broken
userspace" in the patch description which at first glance seemed to be
saying that userspace (i.e. pppd :) is doing something which has
recently been declared to be wrong and therefore it is "broken".

I think "fix broken userspace" as a patch headline is quite
ambiguous.  Something like "Fix bug in conversion to use IDR" would be
more informative.

Paul.
