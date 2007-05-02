From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: ARP Spoofing
Date: Wed, 02 May 2007 14:55:53 -0400
Message-ID: <4638DEB9.90608@hp.com>
References: <4638CDED.4020100@cs.byu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Topher Fischer <javert42@cs.byu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:54235 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767237AbXEBSzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 14:55:54 -0400
In-Reply-To: <4638CDED.4020100@cs.byu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Topher Fischer wrote:
> Does the kernel have any protection against ARP spoofing?  If not, does
> anybody know why not? (As in, nobody has done anything, or because of A,
> B, and C).
> 
> Thanks,
> 

If by arp spoofing you mean receiving arp replies from multiple sources and
trusting all of them, then I haven't seen anything.  I speaking from
experience as having been bitten by this in earlier kernels (2.6.15 and 2.6.17),
it's a pita to diagnose in a large environment.

I don't know the history as to why nothing has has been done.

-vlad

