From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Mon, 16 Sep 2002 09:23:09 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3D85DB3D.DC65A80B@nortelnetworks.com>
References: <20020913222213.69396.qmail@web14006.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Cacophonix <cacophonix@yahoo.com>
List-Id: netdev.vger.kernel.org

Cacophonix wrote:
> 
> --- Chris Friesen <cfriesen@nortelnetworks.com> wrote:

> > This has always confused me.  Why doesn't the bonding driver try and spread
> > all the traffic over all the links?
> 
> Because then you risk heavy packet reordering within an individual flow,
> which can be detrimental in some cases.
> --karthik

I can see how it could make the receiving host work more on reassembly, but if throughput is key,
wouldn't you still end up better if you can push twice as many packets through the pipe?

Chris
