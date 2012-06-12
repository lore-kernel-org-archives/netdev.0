From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCHv2 net-next] ipv4: Add interface option to enable routing
 of 127.0.0.0/8
Date: Tue, 12 Jun 2012 11:13:12 -0700
Message-ID: <4FD786B8.3030205@hp.com>
References: <20120608101859.GH32152@canuck.infradead.org> <20120611.165740.419299184892679723.davem@davemloft.net> <20120612104401.GH28598@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:1246 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351Ab2FLSNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 14:13:14 -0400
In-Reply-To: <20120612104401.GH28598@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2012 03:44 AM, Thomas Graf wrote:
> Routing of 127/8 is tradtionally forbidden, we consider
> packets from that address block martian when routing and do
> not process corresponding ARP requests.

I'd go beyond "traditionally forbidden" and call it something considered 
fundamental.  That 127.0.0.1 (et al) can only be reached by entities on 
the same system is rather deeply ingrained in the collective 
consciousness after 30-odd years.

> This is a sane default but renders a huge address space practically
> unuseable.

This change would make 127/8 a de facto RFC 1918 address right?  It 
would not be publicly routable.  Are there actually entities who have 
exhausted 10/8, 172.16/12 and 192.168/16?

Are there any other stacks which can do this, or would this be an "RFC 
1918" network between (newer)Linux systems only?  (Assuming 
non-newer-linux-based routers would be happy with it)

I cannot say that I'm all that good about practicing the preaching, but 
IPv6 cannot be held-off indefinitely.

rick jones
