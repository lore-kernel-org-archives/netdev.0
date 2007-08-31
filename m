From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Fri, 31 Aug 2007 09:10:44 -0400
Message-ID: <46D81354.3010107@garzik.org>
References: <20070730212333.GA8049@havoc.gtf.org> <alpine.LFD.0.999.0707310349460.17287@enigma.security.iitk.ac.in> <46AE6861.50004@garzik.org> <alpine.LFD.0.999.0707310425360.17287@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Petko Manolov <petkan@users.sourceforge.net>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42131 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755604AbXHaNKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:10:48 -0400
In-Reply-To: <alpine.LFD.0.999.0707310425360.17287@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:
> 
> On Mon, 30 Jul 2007, Jeff Garzik wrote:
> 
>> true, we should just remove the dev==NULL check
> 
> Patch below:
> 
> [PATCH] nmclan_cs: Remove bogus (dev==NULL) check in mace_interrupt()
> 
> The (dev == NULL) check in drivers/net/pcmcia/nmclan_cs.c:mace_interrupt()
> handler is always false, so let's remove it.
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> 
> ---
> 
>  drivers/net/pcmcia/nmclan_cs.c |    6 ------
>  1 files changed, 0 insertions(+), 6 deletions(-)

ACK, but patch does not apply to netdev-2.6.git#upstream alas


