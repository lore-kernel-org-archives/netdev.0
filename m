From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] bridge: implement multicast fast leave
Date: Tue, 04 Dec 2012 15:04:52 +0800
Message-ID: <1354604692.15167.7.camel@cr0>
References: <1354545363-11953-1-git-send-email-amwang@redhat.com>
	 <20121203075316.0b1da39d@nehalam.linuxnetplumber.net>
	 <20121204013838.GA31329@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308Ab2LDHF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 02:05:26 -0500
In-Reply-To: <20121204013838.GA31329@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-04 at 09:38 +0800, Herbert Xu wrote:
> On Mon, Dec 03, 2012 at 07:53:16AM -0800, Stephen Hemminger wrote:
> > On Mon,  3 Dec 2012 22:36:03 +0800
> > Cong Wang <amwang@redhat.com> wrote:
> > 
> > > Fast leave allows bridge to immediately stops the multicast
> > > traffic on the port receives IGMP Leave when IGMP snooping is enabled,
> > > no timeouts are observed.
> > > 
> > > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > > Cc: Stephen Hemminger <shemminger@vyatta.com>
> > > Cc: "David S. Miller" <davem@davemloft.net>
> > > Signed-off-by: Cong Wang <amwang@redhat.com>
> > 
> > I like the feature, and it looks like an oversight in the initial design.
> > Why is this not the default, adding more options obscures it.
> 
> If the port has a bridge on it then you're toast.  I think this
> should be a per-port option.

Per-port sounds better than per-bridge. And I will make it enabled by
default.

Thanks!
