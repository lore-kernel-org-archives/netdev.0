From: Frank Reppin <frank@undermydesk.org>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Wed, 10 Oct 2012 03:25:54 +0200
Message-ID: <5074CEA2.6010504@undermydesk.org>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com> <1339030752.2075.1.camel@jtkirshe-mobl> <1339043085.26966.77.camel@edumazet-glaptop> <1339044752.2075.14.camel@jtkirshe-mobl> <loom.20121009T020718-563@post.gmane.org> <1349762863.21172.3848.camel@edumazet-glaptop> <20121009103629.0000569a@unknown> <5074A9CA.50308@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amazone.undermydesk.org ([213.211.198.100]:47834 "EHLO
	amazone.undermydesk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757274Ab2JJBcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 21:32:51 -0400
In-Reply-To: <5074A9CA.50308@tomt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.10.2012 00:48, Andre Tomt wrote:
> On 09. okt. 2012 19:36, Jesse Brandeburg wrote:
[...]
>> Hints or clues (I'm trying to follow the repro steps mentioned in
>> some related threads) are appreciated.
In our scenario - the SuperMicro X8SIE-LN4 acts
as a router.

eth0 -> uplink
eth1 -> core servers network 192.168.a.b/24
eth2 -> developer employees network 192.168.c.d/24

eth1 and eth2 are hooked into (two different) HP2510-24G
switches (they both show no errors at all).

The switch connected to eth2 connects a bunch of
developers doing day-2-day stuff (commits/checkouts/documentation/
listening to stream music/surfing/email) and the such.

Continously running a ping from ie. 192.168.c.d/24 to
192.168.a.b/24 visualizes those spikes (mostly triplets, where
the first echo reply is quite high and the two following replies
are each around 50 percent faster - but mostly still >500ms) - whenever 
these spikes happen, it feels like the whole net 'stalls'.
Just like Denys Fedoryshchenko stated in

http://www.mail-archive.com/e1000-devel@lists.sourceforge.net/msg05517.html

HTH,
Frank Reppin

-- 
43rd Law of Computing:
         Anything that can go wr
fortune: Segmentation violation -- Core dumped
