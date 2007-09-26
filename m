From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Userspace network stack and netchannels.
Date: Wed, 26 Sep 2007 12:53:03 +0400
Message-ID: <20070926085303.GB13187@2ka.mipt.ru>
References: <20070925180043.GA16698@2ka.mipt.ru> <7e63f56c0709251220s12ab10b5pade5b2c90fa4a8b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Robert Iakobashvili <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53888 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302AbXIZIxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 04:53:19 -0400
Content-Disposition: inline
In-Reply-To: <7e63f56c0709251220s12ab10b5pade5b2c90fa4a8b9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Robert.

On Tue, Sep 25, 2007 at 09:20:44PM +0200, Robert Iakobashvili (coroberti@gmail.com) wrote:
> > 3. Gigabit send/recv benchmark for netchannels and sockets using small
> > packets.
> > http://tservice.net.ru/~s0mbre/blog/devel/networking/2006_10_26.html
> > http://tservice.net.ru/~s0mbre/blog/devel/networking/2006_12_21.html
> >
> 
> Very interesting. Are there any details of your benchmarking available,
> namely, how it was done?
> Have you some comparison profiling data (oprofile) to figure out where
> the advantages are coming from?

Those are throughput tests - one sender, one receiver with different
size of the packet being sent/received. CPU usage was determined via
/proc statistics. My analysis says that reduced number of syscalls is
main improvement factor, but different (non-rfc-compliant) congestion 
control allows faster start and faster recovery.

-- 
	Evgeniy Polyakov
