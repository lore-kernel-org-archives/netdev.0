From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: skbuff data pointer alignment requirement
Date: Sat, 29 Dec 2007 14:04:14 +0100
Message-ID: <20071229130414.GB3125@ami.dom.local>
References: <a967d7d00712201712m6981373ife9a333be7d343e0@mail.gmail.com> <476CEE69.20902@gmail.com> <a967d7d00712281653m5b1a937ch898a5b48f8ee1887@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:53323 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791AbXL2NBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 08:01:50 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1993893ugc.16
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2007 05:01:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <a967d7d00712281653m5b1a937ch898a5b48f8ee1887@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2007 at 04:53:24PM -0800, Keyur Chudgar wrote:
> Hi Jarek,
> 
> > Do you mean hardware requirements of an architecture or a specific driver?
> I meant any hardware requirements of an architecture.
> 
> > So, if you have more than one network card, is it needed by all of them,
> > while other (not network) drivers are happy with default allocations?
> Yes. So, anything related to skbuff data block, will need specific alignment
> requirements, while others (non-network drivers) will work as default.

Hi Keyur,

It seems this is rather unusual case, probably something new, because 
considering the number of various architectures available on Linux it
looks like the first which requires this feature. Then, of course,
your proposal would make sense, but you should simply name this
hardware in your patch description. On the other hand, if it's
something very uncommon, it could be hard for you to convince somebody
to merge this change.

Regards,
Jarek P.
