From: TB <lkml@techboom.com>
Subject: Re: divide error: 0000, in bictcp_cong_avoid, kernel 2.6.39
Date: Mon, 04 Jul 2011 14:10:16 -0400
Message-ID: <4E120208.2090500@techboom.com>
References: <4E11CCC4.2010404@techboom.com> <20110704103622.6294f9ed@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s040.panelboxmanager.com ([72.55.186.60]:58430 "EHLO
	s040.panelboxmanager.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab1GDSLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 14:11:13 -0400
In-Reply-To: <20110704103622.6294f9ed@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-07-04 01:36 PM, Stephen Hemminger wrote:
> Any data about the type of connection, kernel configuration or other
> information that might be useful in reproducing the problem?
> 
> Also please try 2.6.39.2

We haven't found a sure way of reproducing it.
It happened on 1.2% of our servers over the weekend and seems random.
Both are connected with 2 gigabit ports using bonding. Traffic tends to
be heavy, but doesn't seem to be a factor.

Would a .config help ?

Only the very basic filter module for iptables is compiled in.

We will try 2.6.39.2 soon
