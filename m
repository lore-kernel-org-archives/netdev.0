From: Christoph Paasch <christoph.paasch@gmail.com>
Subject: Re: TCP socket receives strange packet
Date: Tue, 14 Oct 2014 09:54:30 -0700
Message-ID: <20141014165430.GI28432@Paaschs-MacBook-Pro.local>
References: <1413298852.17109.3.camel@edumazet-glaptop2.roam.corp.google.com>
 <CABrhC0=y745PHJdmKvPeyiYNAEUX_CHPZo7ekiWJYxLt=pYEkw@mail.gmail.com>
 <20141014164144.GG28432@Paaschs-MacBook-Pro.local>
 <20141014.125004.1504941413142780868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnwheffner@gmail.com, eric.dumazet@gmail.com,
	Yurij.Plotnikov@oktetlabs.ru, netdev@vger.kernel.org,
	Alexandra.Kossovsky@oktetlabs.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:44366 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360AbaJNQyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 12:54:32 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so7997865pad.8
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 09:54:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141014.125004.1504941413142780868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/10/14 - 12:50:04, David Miller wrote:
> From: Christoph Paasch <christoph.paasch@gmail.com>
> Date: Tue, 14 Oct 2014 09:41:44 -0700
> 
> > there was a long discussion whether for the updated version of RFC1323 (now
> > published as RFC 7323) a segment must be dropped if it does not contain a
> > timestamp. The rationale (defended by Joe Touch) was that it must be there to
> > protect against wrapped sequence numbers while others argued that mandating
> > a drop might result in stalling connections if (for one reason or another) a
> > host sends a segment without TS (or a middlebox removed it).
> > 
> > The RFC now says that a host SHOULD drop segments without timestamps.
> 
> There are too many middle-boxes that drop timestamps for that to be a tenable
> way to behave, especially by default.
> 
> If you want to be disconnected from various parts of the internet, feel free
> to follow that RFC's recommendations.

I'm completely with you. We actually argued against Joe Touch, who wanted to
have a  "MUST" for dropping these segments without TS.


Cheers,
Christoph
