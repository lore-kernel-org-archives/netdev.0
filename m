From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Userspace network stack and netchannels.
Date: Tue, 25 Sep 2007 12:34:44 -0700
Message-ID: <20070925123444.10346e99@freepuppy.rosehill>
References: <20070925180043.GA16698@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49176 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751151AbXIYTfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 15:35:24 -0400
In-Reply-To: <20070925180043.GA16698@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Sep 2007 22:00:48 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Hi.
> 
> I've released new version of the extremely small 
> userspace netowork stack [1] implementation.
> Stack supports TCP and UDP over IP.
> It works on top of netchannels [2] or packet socket 
> (returned back in this release).
> 
> Supported features:
> 	* TCP/UDP sending and receiving.
> 	* Timestamp, window scaling, MSS TCP options.
> 	* PAWS.
> 	* Slow start and congestion control.
> 	* Socket-like interface.
> 	* Retransmit and fast retransmit support.
> 	* support for TCP listen state (only point-to-point mode,
> 		i.e. no new data channels are created, when new client is
> 		connected, instead state is changed according to protocol
> 		(TCP state is changed to ESTABLISHED).
> 	* support for the netchannels and packet socket interface.
> 
> It was proven [3] that unetstack can be *much* faster than vanilla TCP
> stack (mainly because of heavily reduced number of syscalls, different
> congestion control algorithm and other features).

I am glad to see a more complete implementation for comparison, but
by changing several variables at once it makes it hard to evaluate whether
the improvement comes from user space TCP or the other changes.
