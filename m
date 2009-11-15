From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sun, 15 Nov 2009 03:55:14 +0200
Message-ID: <200911150355.15204.denys@visp.net.lb>
References: <20091113233504.GQ19478@kvack.org> <20091113.185937.251557071.davem@davemloft.net> <20091115090604.331d75c2@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bcrl@lhnet.ca,
	shemminger@vyatta.com, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59686 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbZKOBxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 20:53:48 -0500
In-Reply-To: <20091115090604.331d75c2@opy.nosense.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 15 November 2009 00:36:04 Mark Smith wrote:
> On the occasions I've looked at whether a Linux box would be an
> alternative to the Cisco BRAS platform we use, the last time I looked
> the number of sessions people were saying they were running was
> 500. I don't consider Linux to be feasible in that role until you're
> able to run at least 5000 sessions on a single box. I'm a bit unusual
I am running up to 3500 on single NAS, but there is only 3 biggest one like 
this, and i am limited only by subscribers on this location (network is 
distributed over the country, and i have around 200 NAS servers running in 
summary). And it is just PC bought from nearest supermarket with cheap PCI 
RTL8169, and similar quality LOM adapter e1000e. Everything running on 
cheapest USB flash from same supermarket.

For my case running Linux NAS on cheap PC's is only choice. It is 3rd world 
country, and many reasons (i can explain each, but it is not technical 
subject) doesn't let me to think, that "professional" equipment is feasible 
for me.

Here people build networks on cheapest unmanageable switches, same 
cost/quality 802.11b/g wireless networks, and only a way to terminate them 
reliably is PPPoE. I know, it is also weak and easy to break, but it is 
single choice i have.
I know also ISP's in Russia, who have somehow partially "managed" networks, 
but PPPoE letting them to drop running costs.

And interface creation speed is important for me, when electricity goes down 
here, many customers disconnects (up to 500 on single NAS), and then join 
again to NAS. Load average was jumping to sky on such situations, just option 
to not create sysfs entries helped me a lot (was posted recently).
Electricity outage is usual here, happens 2-3 times daily.
