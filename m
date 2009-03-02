From: Kyle McMartin <kyle@infradead.org>
Subject: Re: oops / null deref in __inet6_check_established(), kernel
	2.6.29-rc6
Date: Mon, 2 Mar 2009 00:09:19 -0500
Message-ID: <20090302050919.GJ28503@bombadil.infradead.org>
References: <20090224182147.2150468e@dhcp-100-2-144.bos.redhat.com> <20090224.152704.210992553.davem@davemloft.net> <20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com> <20090228031618.GB28503@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Kyle McMartin <kyle@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55119 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbZCBFJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 00:09:27 -0500
Content-Disposition: inline
In-Reply-To: <20090228031618.GB28503@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 10:16:18PM -0500, Kyle McMartin wrote:
> This only seems to show up when CONFIG_NET_NS is enabled. (Reproduced on
> git HEAD with that option on, doesn't occur with the option off.)
> 
> I will confess complete ignorance to the network stack, but this patch
> fixes things... ipv4 seems to have the same namespace support, but
> increments the sock_net, not the twsk_net.
> 
> I'll probably put this patch into Fedora, if only to prevent this from
> being used as a local DoS by an unprivileged user.
> 
> Signed-off-by: Kyle McMartin <kyle@redhat.com>
> 

Any thoughts? This is a pretty serious issue... Granted we should
probably just turn CONFIG_NET_NS off entirely, since it's
underdocumented and should be explicitly labelled as experimental
instead of just depending on it...

regards, Kyle
