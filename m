From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 9 Mar 2011 19:16:03 +0200
Message-ID: <20110309171603.GD7165@redhat.com>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
 <20110309071558.GA25757@redhat.com>
 <201103091009.27932.tahm@linux.vnet.ibm.com>
 <1299689493.25664.120.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29134 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755047Ab1CIRQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 12:16:23 -0500
Content-Disposition: inline
In-Reply-To: <1299689493.25664.120.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2011 at 08:51:33AM -0800, Shirley Ma wrote:
> On Wed, 2011-03-09 at 10:09 -0600, Tom Lendacky wrote:
> > > > Vhost is receiving a lot of notifications for packets that are to
> > be
> > > > transmitted (over 60% of the packets generate a kick_notify). 
> 
> This is guest TX send notification when vhost enables notification.
> 
> In TCP_STREAM test, vhost exits from reaching NAPI WEIGHT,


You mean virtio?

> it rarely
> enables the notification, vhost re-enters handle_tx from NAPI poll,

Does NAPI really call handle_tx? Not rx?

> so
> guest doesn't do much kick_notify.
> 
> In multiple TCP_RR test, seems vhost exits from nothing to send in TX vq
> very often, so it enables notification most of the time.
> 
> Shirley
