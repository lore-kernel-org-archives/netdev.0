From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take22 0/4] kevent: Generic event handling mechanism.
Date: Tue, 07 Nov 2006 07:02:49 -0500
Message-ID: <455075E9.4080202@garzik.org>
References: <1154985aa0591036@2ka.mipt.ru> <1162380963981@2ka.mipt.ru>	 <20061101130614.GB7195@atrey.karlin.mff.cuni.cz>	 <20061101132506.GA6433@2ka.mipt.ru> <20061101160551.GA2598@elf.ucw.cz>	 <20061101162403.GA29783@2ka.mipt.ru>	 <slrnekhpbr.2j1.olecom@flower.upol.cz>	 <20061101185745.GA12440@2ka.mipt.ru> <5c49b0ed0611011812w8813df3p830e44b6e87f09f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	LKML <linux-kernel@vger.kernel.org>,
	Oleg Verych <olecom@flower.upol.cz>,
	Pavel Machek <pavel@ucw.cz>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20409 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1754210AbWKGMC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 07:02:59 -0500
To: Nate Diller <nate.diller@gmail.com>
In-Reply-To: <5c49b0ed0611011812w8813df3p830e44b6e87f09f4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nate Diller wrote:
> Indesiciveness has certainly been an issue here, but I remember akpm
> and Ulrich both giving concrete suggestions.  I was particularly
> interested in Andrew's request to explain and justify the differences
> between kevent and BSD's kqueue interface.  Was there a discussion
> that I missed?  I am very interested to see your work on this
> mechanism merged, because you've clearly emphasized performance and
> shown impressive results.  But it seems like we lose out on a lot by
> throwing out all the applications that already use kqueue.


kqueue looks pretty nice, the filter/note models in particular.  I don't 
see anything about ring buffers though.

I also wonder about the asynchronous event side (send), not just the 
event reception side.

	Jeff


