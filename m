From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sat, 28 Aug 2004 23:15:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040828231529.051a73cc.davem@davemloft.net>
References: <412A8FB5.4080700@trash.net>
	<OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@redhat.com, laforge@netfilter.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 15:28:07 -0600
David Stevens <dlstevens@us.ibm.com> wrote:

> In that case, it appears that conntrack needs to flush the entire
> frag queue when it's unloaded. That shouldn't happen much,
> so maybe that's not such a bad idea.

I think I agree with David now that I've read through this a few
times.  Can someone send me a patch which does this?

Does 2.4.x have this problem too?  I thought it didn't.
