From: Noel Grandin <noelgrandin@gmail.com>
Subject: Re: TCP and reordering
Date: Thu, 29 Nov 2012 15:10:45 +0000 (UTC)
Message-ID: <loom.20121129T160915-947@post.gmane.org>
References: <20121127.210611.1127622873924794001.davem@davemloft.net>  <1354089566.21562.20.camel@shinybook.infradead.org>  <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com>  <1354093703.21562.23.camel@shinybook.infradead.org>  <1354100552.14302.78.camel@edumazet-glaptop>  <1354103355.21562.46.camel@shinybook.infradead.org>  <1354105619.14302.89.camel@edumazet-glaptop>  <1354106362.21562.51.camel@shinybook.infradead.org>  <1354107140.14302.140.camel@edumazet-glaptop>  <1354117635.21562.63.camel@shinybook.infradead.org>  <20121128161930.GB19042@kvack.org>  <1354120887.21562.87.camel@shinybook.infradead.org>  <1354122996.14302.427.camel@edumazet-glaptop> <1354125688.21562.95.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48384 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751349Ab2K2PPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 10:15:03 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Te5pR-0001ME-Hg
	for netdev@vger.kernel.org; Thu, 29 Nov 2012 16:15:05 +0100
Received: from 41.164.8.42 ([41.164.8.42])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 16:15:05 +0100
Received: from noelgrandin by 41.164.8.42 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 16:15:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2 <at> infradead.org> writes:
> On Wed, 2012-11-28 at 09:16 -0800, Eric Dumazet wrote:
> > BQL was really something to control/limit queueing on ethernet links,
> > not for stacked devices, as stacked devices normally have no queue.
> 
> Stacked devices have more queue than anything else :)
> 

Surely BQL is something that should only be implemented on the device at the 
bottom of the stack, and everything above that shouldn't be bothering?
