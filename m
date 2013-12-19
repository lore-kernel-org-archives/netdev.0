From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Thu, 19 Dec 2013 16:48:42 +0100
Message-ID: <20131219154842.GA25851@order.stressinduktion.org>
References: <20131219144816.33310@gmx.com> <20131219150923.GB24118@order.stressinduktion.org> <52B30D99.5090504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39943 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab3LSPsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 10:48:43 -0500
Content-Disposition: inline
In-Reply-To: <52B30D99.5090504@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 07:15:37AM -0800, Ben Greear wrote:
> On 12/19/2013 07:09 AM, Hannes Frederic Sowa wrote:
> >On Thu, Dec 19, 2013 at 03:48:16PM +0100, Bob Falken wrote:
> >>Hello, I have an issue after kernel 2.6.37 and above.
> >>If i roll back to kernel 2.6.36.4 everything is fine.
> >>if recive more than 4294967295 multicast packets, the kernel does not 
> >>register the multicast packets. and multicast routing does not 
> >>functioning.
> >>(Tested bouth FIB_HASH and FIB_TRIE)
> >>Tested with xorp and pimd.
> >>I have abount 24 multicast groups, and it takes me about 17hours to 
> >>reproduce the issue after a reboot.
> >>Reboot is reqired to fix the issue. (Tested to stop/start pimd/xorp, 
> >>reload network module for the network interface "e1000e",
> >>Used birdge adapter and remove bridge adapter and readd bridge adapter to 
> >>clear counters. none of thouse solves the issue.)
> >
> >Please test this with a recent kernel. 2.6.37 is really old and you 
> >normally
> >won't get good support here with such old kernels.
> 
> Note that he did test up to 3.11.9 and it still showed failures.

Oh sorry, I did not read to the end. ;)

An interesting hint could be to use dropwatch or perf script net_dropmonitor
to check where the fragments get dropped. Also nstat could give additional
hints where something might get wrong. Please use a recent kernel while
debugging this issue. Maybe a patch can get backported later.

Thanks,

  Hannes
