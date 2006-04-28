From: "David S. Miller" <davem@davemloft.net>
Subject: Re: E1000 stopped transmitting in rc3.
Date: Fri, 28 Apr 2006 00:14:40 -0700 (PDT)
Message-ID: <20060428.001440.33235399.davem@davemloft.net>
References: <20060428001352.GA3319@redhat.com>
	<445175D4.8010209@foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23234
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030278AbWD1HOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 03:14:36 -0400
To: sofar@foo-projects.org
In-Reply-To: <445175D4.8010209@foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <sofar@foo-projects.org>
Date: Thu, 27 Apr 2006 18:54:28 -0700

> Dave Jones wrote:
> > With 2.6.17-rc3, my E1000 won't get a dhcp lease.
> > Looking at tcpdump and ifconfig output, it's easy to see why.
> > It's recieving packets, but the packets transmitted field
> > of ifconfig never increases.
> > 
> > The last version I have built that worked ok was 2.6.17rc2-git3
> 
> *puzzled*
> 
> the only patch between 2.6.17rc2 and 2.6.17rc3 contains an rx-path patch, but 
> nothing that affects tx. All the other patches sent earlier are queued for 
> 2.6.18 so they don't apply.

If the rx path is corrupting the packets or providing bad
checksums, there will be nothing to transmit back.

So RX changes could explain the behavior.
