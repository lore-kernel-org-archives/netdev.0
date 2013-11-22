From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Question about IPv6 neighbor discovery and 6lowpan
Date: Fri, 22 Nov 2013 10:29:06 +0700
Message-ID: <692AEC23-372B-48A9-BEA7-02C2F6C13A47@holtmann.org>
References: <1385046178.2723.17.camel@jrissane-mobl.ger.corp.intel.com> <20131121153414.GA9960@omega> <1385049135.2723.25.camel@jrissane-mobl.ger.corp.intel.com>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53358 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575Ab3KVD3y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 22:29:54 -0500
In-Reply-To: <1385049135.2723.25.camel@jrissane-mobl.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

>>> I am investigating RFC 6775 (Neighbor Discovery Optimization for IPv6
>>> over Low-Power Wireless Personal Area Networks (6LoWPANs))
>>> http://tools.ietf.org/html/rfc6775
>>> 
>>> The RFC suggests some changes to neighbor discovery procedure for the
>>> 6LoWPAN networks. I was looking net/ipv6/ndisc.c and it seems that
>>> ARPHRD type (from type field in net_device struct) is the only way to
>>> detect and change the discovery procedure in the ndisc.c code. Am I
>>> right with this assumption here?
>>> 
>> I think you are right, there was some patches on linux-zigbee-devel who
>> use exact the same idea to check the ARPHRD type.
> 
> Ok. The reason I was interested in about this is that I proposed new
> ARPHRD_RAWIP earlier that I could use in BT LE 6lowpan code. Now I think
> that type might be too generic and perhaps I should have ARPHRD_6LOWPAN
> or even ARPHRD_BT_6LOWPAN.

if it can be shared between 802.15.4 and Bluetooth, then I would propose to use ARPHRD_6LOWPAN and also convert the 802.15.4 stack to use that one.

Regards

Marcel
