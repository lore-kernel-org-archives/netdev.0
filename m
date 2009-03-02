From: David Miller <davem@davemloft.net>
Subject: Re: oops / null deref in __inet6_check_established(), kernel
 2.6.29-rc6
Date: Sun, 01 Mar 2009 21:28:57 -0800 (PST)
Message-ID: <20090301.212857.264627839.davem@davemloft.net>
References: <20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com>
	<20090228031618.GB28503@bombadil.infradead.org>
	<20090302050919.GJ28503@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org
To: kyle@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51158
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbZCBF3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 00:29:15 -0500
In-Reply-To: <20090302050919.GJ28503@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@infradead.org>
Date: Mon, 2 Mar 2009 00:09:19 -0500

> On Fri, Feb 27, 2009 at 10:16:18PM -0500, Kyle McMartin wrote:
> > This only seems to show up when CONFIG_NET_NS is enabled. (Reproduced on
> > git HEAD with that option on, doesn't occur with the option off.)
> > 
> > I will confess complete ignorance to the network stack, but this patch
> > fixes things... ipv4 seems to have the same namespace support, but
> > increments the sock_net, not the twsk_net.
> > 
> > I'll probably put this patch into Fedora, if only to prevent this from
> > being used as a local DoS by an unprivileged user.
> > 
> > Signed-off-by: Kyle McMartin <kyle@redhat.com>
> > 
> 
> Any thoughts? This is a pretty serious issue... Granted we should
> probably just turn CONFIG_NET_NS off entirely, since it's
> underdocumented and should be explicitly labelled as experimental
> instead of just depending on it...

It's in my queue, I just haven't gotten to it yet.

Serious issue or not you have to be patient.
