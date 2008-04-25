From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem release.
Date: Sat, 26 Apr 2008 01:03:15 +0400
Message-ID: <20080425210315.GA3712@2ka.mipt.ru>
References: <20080425150756.GA28369@2ka.mipt.ru> <87wsmlx2w1.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51099 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759221AbYDYVDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 17:03:36 -0400
Content-Disposition: inline
In-Reply-To: <87wsmlx2w1.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Apr 25, 2008 at 07:25:50PM +0200, Andi Kleen (andi@firstfloor.org) wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> 
> > It is work-in-progress, and network protocol is not stable yet.
> 
> Congratulations. I'm sure it was a lot of work.

Well, not _that_ lot of work, but it is interesting, so...
It was at least once time rewriten mostly from scratch to allow all those
shiny things. It is not in-advance design, but kind of evolution based
on my filesystem studying.

> But could you please quickly expand how useful it is at this state? Is
> it already far enough that someone could save some data on it and use
> it without it crashing all the time?
> 
> It's unclear even from your status report.

Well, it does not crash in iozone, huge untar, kernel compilations
and big file copies. And it works reliably enough to make md5 sums be
equal on both server and clients, but I will not be surprised if it
contains some bugs. I also will not be surprised, if current server 
behaviour does not match POSIX expectations (I'm curios of NFS
matches that), but at least this behaviour will be much more clean
with transaction introduction and server support for them.

So, it works for usual NFS-like workload, but since it is rather young
FS (this particular design implementation exists for about couple of
months), there may be some questions...

Getting that POHMELFS is really simple and its design is oriented to be
as open as possible without burden of old age problems and
compatibilities, it is not a any kind of a problem to locate and fix a
bug, so I'm very open for any kind of reports.

-- 
	Evgeniy Polyakov
