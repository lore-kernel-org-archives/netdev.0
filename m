From: David Lamparter <equinox@diac24.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 22:40:38 +0100
Message-ID: <20120119214038.GB3347849@jupiter.n2.diac24.net>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
 <20120119.143105.735366189369504929.davem@davemloft.net>
 <20120119195349.GN2262734@jupiter.n2.diac24.net>
 <20120119.152752.318442465605898328.davem@davemloft.net>
 <m1lip32xoi.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, equinox@diac24.net,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:48250 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850Ab2ASVku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 16:40:50 -0500
Content-Disposition: inline
In-Reply-To: <m1lip32xoi.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2012 at 01:24:13PM -0800, Eric W. Biederman wrote:
> This thread is a fascinating disconnect from reality all of the way
> around.
> 
> - inet_twsk_purge already implements throwing out of timewait sockets
>   when a network namespaces is being cleaned up.  So the RFC is nonsense.

Indeed it does. Thanks for pointing that out, I should've tested that
first thing... I'm sorry, I'll try better next time.

Hans, I guess if you experienced delays on netns closing, they must have
a different source? Maybe there's a bug in another place that should be
cleaned up on namespace exit?


-David
