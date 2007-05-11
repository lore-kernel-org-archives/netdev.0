From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 13:56:02 +0400
Message-ID: <20070511095602.GA5762@2ka.mipt.ru>
References: <20070511093202.GB24695@2ka.mipt.ru> <OF6C27DF4E.9060BDB4-ON652572D8.0035C627-652572D8.00363827@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Ian McDonald <ian.mcdonald@jandi.co.nz>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49871 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755945AbXEKJ4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 05:56:23 -0400
Content-Disposition: inline
In-Reply-To: <OF6C27DF4E.9060BDB4-ON652572D8.0035C627-652572D8.00363827@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 03:22:13PM +0530, Krishna Kumar2 (krkumar2@in.ibm.com) wrote:
> > No locks, no requeues? Seems simple imho.
> 
> I will analyze this in more detail when I return (leaving just now, so got
> really no time). The only issue that I see quickly is "No locks", since to
> get things off the queue you need to hold the queue_lock.

I meant no locks during processing of the packets (pci read/write, dma
setup and so on), of course it is needed to dequeue a packet, but only
for that operation.

-- 
	Evgeniy Polyakov
