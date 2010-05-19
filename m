From: Kyle McMartin <kmcmartin@redhat.com>
Subject: Re: r8169 transmit queue time outs
Date: Wed, 19 May 2010 09:48:49 -0400
Message-ID: <20100519134849.GJ3900@ihatethathostname.lab.bos.redhat.com>
References: <20100506141715.GC4480@ihatethathostname.lab.bos.redhat.com>
 <20100506201024.GA3541@electric-eye.fr.zoreil.com>
 <20100519134344.GI3900@ihatethathostname.lab.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	dgilmore@redhat.com
To: Kyle McMartin <kmcmartin@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587Ab0ESNsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 09:48:52 -0400
Content-Disposition: inline
In-Reply-To: <20100519134344.GI3900@ihatethathostname.lab.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 09:43:44AM -0400, Kyle McMartin wrote:
> I provided a bunch of testers with a backport of the current git head
> r8169 driver, and sadly, they report the TX timeout issues still occur.
> :/
> 
> Any other ideas?
> 

They note the vendor driver seems to work without these transmit
timeouts... Would it be worthwhile for me to take a look and compare the
tx setup between these git head and the vendor latest driver?

regards, Kyle
