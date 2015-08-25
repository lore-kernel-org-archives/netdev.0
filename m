From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 09/13] vxlan: provide access function for vxlan
 socket address family
Date: Tue, 25 Aug 2015 18:12:43 +0200
Message-ID: <20150825181243.26f9ff99@griffin>
References: <cover.1439929916.git.jbenc@redhat.com>
	<a07e8ad2f7cfc3153d569a2b3f366bf17b2f348a.1439929916.git.jbenc@redhat.com>
	<E8BB0745-6652-4539-BE59-6E0DD0977B2F@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816AbbHYQMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 12:12:46 -0400
In-Reply-To: <E8BB0745-6652-4539-BE59-6E0DD0977B2F@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2015 00:34:18 +0000, Rustad, Mark D wrote:
> > --- a/include/net/vxlan.h
> > +++ b/include/net/vxlan.h
> > @@ -241,3 +241,8 @@ static inline void vxlan_get_rx_port(struct net_device *netdev)
> > }
> > #endif
> > #endif
> > +
> > +static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
> > +{
> > +	return vs->sock->sk->sk_family;
> > +}
> 
> This causes build problems because vxlan_get_sk_family is not inside the #endif
> protecting the file for multiple inclusion. Please put vxlan_get_sk_family
> inside the last #endif.

That's what happens when you rebase the whole set several times :-/
Thanks for the report. I'll send a patch.

 Jiri

-- 
Jiri Benc
