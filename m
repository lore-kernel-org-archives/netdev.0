From: Paul Jakma <paul@clubi.ie>
Subject: Re: possible problem with TSO and ip_queue
Date: Wed, 10 May 2006 21:07:31 +0100 (IST)
Message-ID: <Pine.LNX.4.64.0605102105290.3813@sheen.jakma.org>
References: <Pine.LNX.4.64.0605101815430.16614@nacho.alt.net>
	<20060510.124955.114056211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: ccaputo@alt.net, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060510.124955.114056211.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wed, 10 May 2006, David S. Miller wrote:

> This is by design.  Netfilter looks at full TSO frames,

That explains it.

> Once you add MD5 checksums to the TCP packet, TSO can no longer be 
> used on that path, so you'll have to disable TSO either in the 
> route or via some other means.

Ok.

Is there a better way to deal with TSO besides documenting:

"disable TSO on all interfaces which /ever/ potentially could be used
  to reach TCP-MD5 authenticated BGP peers."

?

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
Nothing ever becomes real until it is experienced.
- John Keats
