From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug 10238] Re: [PATCH] Re: netconsole still hangs
Date: Wed, 19 Mar 2008 22:54:45 +0100
Message-ID: <20080319215445.GA3505@ami.dom.local>
References: <20080318015006.3f0efb8e.akpm@linux-foundation.org> <20080318210542.GA2764@ami.dom.local> <20080318144742.83f544f9.akpm@linux-foundation.org> <20080318224729.GA2760@ami.dom.local> <20080319191724.GA2756@ami.dom.local> <20080319142010.ed564c39.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:13303 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938943AbYCSVvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 17:51:15 -0400
Received: by ug-out-1314.google.com with SMTP id z38so1331838ugc.16
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 14:51:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080319142010.ed564c39.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2008 at 02:20:10PM -0700, Andrew Morton wrote:
...
> No.  I still haven't retested on the other offending machine.  Right now
> I'm not sure that we any longer have anything which needs fixing.  Apart
> from merging netpoll-zap_completion_queue-adjust-skb-users-counter.patch?

I agree that at least there seems to be no proof of a regression which
needs fixing. But I bet there are still things in netpoll, like this
zap_completion_queue, which could be (not urgently) fixed...

Jarek P. 
