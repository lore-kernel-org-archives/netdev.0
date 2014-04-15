From: Dennis Punjabi <linuxdev@icts.bz>
Subject: RE: 802.1AD packets - Kernel changes ether type from 88A8 to 8100
 on all packets.
Date: Tue, 15 Apr 2014 01:34:47 +0000
Message-ID: <BLU184-W5932FDD379FA1C7DFFA92FD0500@phx.gbl>
References: <BLU184-W706F779E20884E4F486ED9D0540@phx.gbl>,<1397319636.1789.11.camel@localhost.localdomain>,<5349729C.3020602@redhat.com>,<87sipgsen9.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Toshiaki Makita <toshiaki.makita1@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Atzm Watanabe <atzm@stratosphere.co.jp>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu0-omc4-s14.blu0.hotmail.com ([65.55.111.153]:2941 "EHLO
	blu0-omc4-s14.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750828AbaDOBjx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 21:39:53 -0400
In-Reply-To: <87sipgsen9.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Hi.
>>>
>>> Though I'm not an expert with libpcap, I feel tcpdump sometimes shows a
>>> wrong vlan protocol (if vlan_tci is used).
>>>
>>> Maybe this topic has relevance?
>>>
>>> packet: deliver VLAN TPID to userspace
>>> http://marc.info/?l=linux-netdev&m=138728859001934&w=2
>>> http://marc.info/?l=linux-netdev&m=138728859601935&w=2
>>> http://marc.info/?l=linux-netdev&m=138728860101937&w=2
>>> http://marc.info/?l=linux-netdev&m=138728860601939&w=2
>>
>> The issue seems not to be in AF_PACKET as it just 'playes dumb' and propagates
>> what has been set in the skb as metadata to user space e.g., see ...
>
> Yes.
> Also I sent a small pull-request for libpcap via github to fix this
> issue about 2 weeks ago, but it is not pulled yet, still opened:
>
> https://github.com/the-tcpdump-group/libpcap/pull/346


Thanks Atzm and everyone for clarifying that and pointing me in the right direction.
Was not too sure where to begin looking.

I will apply the individual patches and try the 802.1AD filtering on the bridge.
Appreciate your help.

Best Regards,
Dennis
 		 	   		  