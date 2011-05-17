From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Tue, 17 May 2011 09:21:11 +0300
Message-ID: <20110517062111.GD26989@redhat.com>
References: <1305574128.3456.23.camel@localhost.localdomain>
 <1305574518.2885.25.camel@bwh-desktop>
 <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop>
 <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16501 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841Ab1EQGVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 02:21:20 -0400
Content-Disposition: inline
In-Reply-To: <1305588738.3456.65.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 04:32:18PM -0700, Shirley Ma wrote:
> Hello Michael,
> 
> Looks like to use a new flag requires more time/work.
> I am thinking
> whether we can just use HIGHDMA flag to enable zero-copy in macvtap to
> avoid the new flag for now since mavctap uses real NICs as lower device?
> 
> Thanks
> Shirley

Problem is, in your patch there are a set of restrictions on what the
device can do with the skb that we need to enforce somehow.
Also, how do we know it's a 'real NIC' and not a software device?

-- 
MST
