From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Wed, 21 Mar 2012 18:00:03 +0100
Message-ID: <20120321170003.GA5533@netboy.at.omicron.at>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
 <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jacob.e.keller@intel.com, jeffrey.t.kirsher@intel.com,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43985 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754262Ab2CURAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 13:00:21 -0400
Received: by wejx9 with SMTP id x9so1123723wej.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 10:00:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 21, 2012 at 11:00:59AM -0400, chetan loke wrote:
> Once PHC->gettime goes live(aka exported to user space), we can't
> really control how users will use it in their applications. There
> could be 100+ apps all trying to get real-time from the network to do
> some time-keeping stuff. They might pound the ioctls at high rate. The
> last thing we would want is to self-induce a light weight DOS. What
> Eric Dumazet mentioned in the very first patch set seems like a good
> comment. seqlock or whatever it is we use for jiffies.

Can you please explain how using a seqlock could help here?

Thanks,
Richard
