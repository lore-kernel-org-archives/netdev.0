From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sun, 22 Aug 2004 22:03:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040822220331.561fc276.davem@redhat.com>
References: <20040818091352.GB6507@suse.de>
	<20040819101159.GC3921@sunbeam.de.gnumonks.org>
	<20040819071846.2d0d6120.davem@redhat.com>
	<4124BF7E.7090304@trash.net>
	<20040819081428.5243e314.davem@redhat.com>
	<412765DC.30600@trash.net>
	<20040821221344.6dbc98ed.davem@redhat.com>
	<41289859.2040803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, okir@suse.de, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41289859.2040803@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 22 Aug 2004 14:58:01 +0200
Patrick McHardy <kaber@trash.net> wrote:

> The first fragment (offset=0) is given to ip_defrag by conntrack
> at PRE_ROUTING, without a dst_entry. Then conntrack is unloaded.
> Further fragments are now queued in ip_local_deliver. When the
> packet is reassembled and "continues" its way from
> ip_local_deliver, it doesn't have a dst_entry.
> 
> The opposite way is of course also possible, packets queued in
> ip_local_deliver can jump and appear in the PRE_ROUTING hook
> when conntrack is loaded, but that way doesn't seem to cause
> problems.

Thanks for the explanation Patrick.

Let me brain storm on this on Monday (tomorrow).
