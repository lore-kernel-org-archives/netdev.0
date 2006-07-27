From: Jens Axboe <axboe@suse.de>
Subject: Re: async network I/O, event channels, etc
Date: Thu, 27 Jul 2006 10:39:16 +0200
Message-ID: <20060727083916.GM5282@suse.de>
References: <20060727081114.GH5282@suse.de> <20060727.012037.78156999.davem@davemloft.net> <20060727082924.GK5282@suse.de> <20060727.013707.101482735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.virtualhost.dk ([195.184.98.160]:53314 "EHLO virtualhost.dk")
	by vger.kernel.org with ESMTP id S932344AbWG0Ij2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 04:39:28 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060727.013707.101482735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27 2006, David Miller wrote:
> From: Jens Axboe <axboe@suse.de>
> Date: Thu, 27 Jul 2006 10:29:24 +0200
> 
> > Precisely. And this is the bit that is currently still broken for
> > splice-to-socket, since it gives that ack right after ->sendpage() has
> > been called. But that's a known deficiency right now, I think Alexey is
> > currently looking at that (as well as receive side support).
> 
> That's right, I was discussing this with him just a few days ago.
> 
> It's good to hear that he's looking at those patches you were working
> on several months ago.

It is. I never ventured much into the networking part, just noted that
as a current limitation with the ->sendpage() based approach. Basically
we need to pass more info in, which also gets rid of the limitation of
passing a single page at the time.

-- 
Jens Axboe

