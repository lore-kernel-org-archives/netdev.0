From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] virtual netlink device for packet sockets
Date: Mon, 24 Jun 2013 16:39:48 -0700 (PDT)
Message-ID: <20130624.163948.896814553052733547.davem@davemloft.net>
References: <1371836288-13122-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860Ab3FXXjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 19:39:49 -0400
In-Reply-To: <1371836288-13122-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 21 Jun 2013 19:38:05 +0200

> This set allows for a virtual netlink device that can be easily used
> without modification by tools like tcpdump, Wireshark et al. to debug
> and troubleshoot netlink traffic that is exchanged between user and
> kernel space. We could even record pcap files for a later analysis.
> No code change would be needed on the side of such analyzers, except
> adding a simple protocol dissector, for example.
> 
> Please have a look at the main description in patch 3. Patch 1 and 2
> are just prerequisits for the actual 3rd patch.
> 
> I think the device idea is the cleanest solution. We have packet sockets
> and they do exactly what we want and expect from them, they have all the
> features etc, and user space would not even need to implement code. Thus
> adding more and more functionality into af_netlink would be a bigger
> surgery and further bloat it up with duplicate code, imho. By taking the
> approach with what I'm proposing, we have a clean segregation of
> functionality (as: packet sockets vs. netlink sockets), thus keeping it
> simple and stupid, and not too complex. 

Yep, this seems like a good tradeoff.  Series applied, thanks!
