From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tcp: efficient port randomisation (rev 3)
Date: Wed, 8 Dec 2004 23:55:24 -0800
Message-ID: <20041208235524.202ff3a1.davem@davemloft.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<20041202135252.04e64f51.davem@davemloft.net>
	<41B14E57.5080803@osdl.org>
	<200412060918.04441.michael.vittrup.larsen@ericsson.com>
	<20041206094234.34861c78@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: michael.vittrup.larsen@ericsson.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041206094234.34861c78@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Dec 2004 09:42:34 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Third revision of the TCP port randomization patch. It randomizes
> TCP ephemeral ports of incoming connections using variation of existing
> sequence number hash. This one avoids the MD4 for the loopback case since 
> there is no reason to bother over loopback and it improves benchmark numbers.

I don't think the loopback optimization is really necessary.
And in any event, RTCF_LOCAL doesn't necessarily mean that
the connection doesn't go "on the wire" especially when using
Julian's "send to self" patch which I might add at some point.

Anyways, please resend to me the version without the loopback
hack and I'll add it to my 2.6.11 queue.

Thanks Stephen and Michael.
