From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sun, 29 Aug 2004 12:57:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829125708.5aa70469.davem@davemloft.net>
References: <412A8FB5.4080700@trash.net>
	<OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com>
	<20040828231529.051a73cc.davem@davemloft.net>
	<4132303C.2060807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, davem@redhat.com, laforge@netfilter.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4132303C.2060807@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 29 Aug 2004 21:36:28 +0200
Patrick McHardy <kaber@trash.net> wrote:

> David S. Miller wrote:
> 
> >I think I agree with David now that I've read through this a few
> >times.  Can someone send me a patch which does this?
> >  
> >
> Attached. The first patch still crashed, we need to prevent new
> fragments from getting queued after the queue is flushed until the
> hook in unregistered.

While we're doing this, is your patch similar to one of the two
original ones that Olaf Kirch posted?  I want to give him proper
attribution, in whatever form is reasonable, that's all.

> >Does 2.4.x have this problem too?  I thought it didn't.
> >  
> >
> I'll have a look, but I think it does.

Thanks a lot for helping out with this Patrick.
