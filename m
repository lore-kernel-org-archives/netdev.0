From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Wed, 6 Oct 2004 18:08:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006180826.4a092c71.davem@davemloft.net>
References: <41633174.7070805@candelatech.com>
	<16740.17875.574967.11417@robur.slu.se>
	<41646587.7070401@candelatech.com>
	<41649425.1010102@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41649425.1010102@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 06 Oct 2004 17:56:05 -0700
Ben Greear <greearb@candelatech.com> wrote:

> It may be that other programs would like to use the notify_queue_woken hook, so
> if this were ever to hit the kernel proper, might want to make this a linked list
> of callbacks instead of a simple pointer.

This sort of suggests that pktgen may be better implemented
via a kind of special queueing discipline.  Just an idea.
