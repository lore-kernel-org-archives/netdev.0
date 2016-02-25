From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next v2 1/5] netdev: introduce ndo_set_rx_headroom
Date: Thu, 25 Feb 2016 16:37:33 +0100
Message-ID: <1456414653.5100.39.camel@redhat.com>
References: <cover.1456397229.git.pabeni@redhat.com>
	 <94f5bf927e514df4fecd50a1332a56501fff2945.1456397229.git.pabeni@redhat.com>
	 <56CF0DEC.6030308@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@kernel.org>,
	Flavio Leitner <fbl@sysclose.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760752AbcBYPhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 10:37:40 -0500
In-Reply-To: <56CF0DEC.6030308@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-25 at 17:21 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 2/25/2016 2:09 PM, Paolo Abeni wrote:
> 
> > This method allows the controlling device (i.e. the bridge) to specify
> > additional headroom to be allocated for skb head on frame reception.
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> >
> > ---
> > v1 -> v2:
> >   - fixed netdev_get_fwd_headroom()
> >   - added netdev_set_rx_headroom() and netdev_reset_rx_headroom() helpers
> > ---
> >   include/linux/netdevice.h | 31 +++++++++++++++++++++++++++++++
> >   1 file changed, 31 insertions(+)
> >
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index e52077f..8f53674 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1093,6 +1093,12 @@ struct tc_to_netdev {
> >    *	This function is used to get egress tunnel information for given skb.
> >    *	This is useful for retrieving outer tunnel header parameters while
> >    *	sampling packet.
> > + * * int (*ndo_set_rx_headroom)(struct net_device *dev, int needed_headroom);
> 
>     It's *void* in the declaration.

You are right, thank you! must be 'void' here, too.

I'll fix it in v3.

Paolo
