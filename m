From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Sat, 29 Jun 2013 09:26:08 -0700
Message-ID: <1372523168.3301.302.camel@edumazet-glaptop>
References: <51CBAA48.3080802@oracle.com>
	   <1372311118.3301.214.camel@edumazet-glaptop>
	 <51CD0E67.4000008@oracle.com>
	   <1372402340.3301.229.camel@edumazet-glaptop>
	  <1372412262.3301.251.camel@edumazet-glaptop> <51CE1E19.3020108@oracle.com>
	 <1372490428.3301.300.camel@edumazet-glaptop>
	 <51CF0723.9020604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Jin <joe.jin@oracle.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zheng.x.li@oracle.com" <zheng.x.li@oracle.com>,
	Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:43817 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab3F2Q0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 12:26:04 -0400
In-Reply-To: <51CF0723.9020604@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 09:11 -0700, Ben Greear wrote:

> Do you know if your patch should go in 3.9?
> 

Yes it should.

> Your test case sounds a bit like what gives us the rare crash in tcp_collapse
> (we have lots of bouncing wifi interfaces running slow-speed TCP trafic).  But,
> it takes days for us to hit the problem most of the time.

Well, unfortunately that's a different problem :(
