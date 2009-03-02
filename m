From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Mon, 2 Mar 2009 15:46:23 +0200
Message-ID: <200903021546.24187.denys@visp.net.lb>
References: <20090226175247.5e56910f@nehalam> <Pine.LNX.4.64.0903021427570.27363@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59945 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbZCBNqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 08:46:34 -0500
In-Reply-To: <Pine.LNX.4.64.0903021427570.27363@ask.diku.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 02 March 2009 15:42:33 Jesper Dangaard Brouer wrote:
> On Thu, 26 Feb 2009, Stephen Hemminger wrote:
> > This is a simple little iptables match that can be used to create the
> > Strong End System model, that router and other non-Linux customers
> > expect. There are management and other applications that use ping and
> > expect to only get a response when the interface with that address is up.
> > Normally, a Linux system will respond to a packet that arrives for any of
> > the system addresses independent of which link it arrives on.
>
> Is this no almost the same as:
>
>   echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
>
I guess if some "smart guy" will set static association in his ARP table, he 
can ignore this rule and "hack the host" over another ip, which sits on 
internal interface for example.
