From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Mon, 09 Feb 2009 17:09:21 +0100
Message-ID: <49905531.3030503@trash.net>
References: <20090129172030.GA2189@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58302 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652AbZBIQJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 11:09:24 -0500
In-Reply-To: <20090129172030.GA2189@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi.
> 
> Passive OS fingerprinting netfilter module allows to passively detect
> remote OS and perform various netfilter actions based on that knowledge.
> This module compares some data (WS, MSS, options and it's order, ttl, df
> and others) from packets with SYN bit set with dynamically loaded OS
> fingerprints.
> 
> Fingerprint matching rules can be downloaded from OpenBSD source tree
> and loaded via netlink connector into the kernel via special util found
> in archive. It will also listen for events about matching packets.
> 
> Archive also contains library file (also attached), which was shipped
> with iptables extensions some time ago (at least when ipt_osf existed
> in patch-o-matic).
> 
> This release moves all rules initialization to be handled over the
> netlink and introduces lookup tables to speed-up RCU finger matching
> a bit. Also fixed module unloading RCU completion race noticed by
> Paul McKenney.

Sorry for ignoring this for so long. I really don't have much of an
opinion on this except for what I said before:

- I would prefer a mechanism built on u32 if possible

- I want to hear at least one person speaking in favour of inclusion
   since I don't have much of an opinion of my own, but am somewhat
   doubtful how useful this is

I guess you could call Paul's "cool stuff" that, but please resend
once more to netfilter-devel :) Anyone who thinks this is useful
please speak up.

