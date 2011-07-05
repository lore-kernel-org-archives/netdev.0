From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: divide error: 0000, in bictcp_cong_avoid, kernel 2.6.39
Date: Tue, 5 Jul 2011 10:16:18 -0700
Message-ID: <20110705101618.744bbab0@nehalam.ftrdhcpuser.net>
References: <4E11CCC4.2010404@techboom.com>
	<20110704103622.6294f9ed@nehalam.ftrdhcpuser.net>
	<4E120208.2090500@techboom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: TB <lkml@techboom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50011 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752328Ab1GERQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 13:16:22 -0400
In-Reply-To: <4E120208.2090500@techboom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 Jul 2011 14:10:16 -0400
TB <lkml@techboom.com> wrote:

> On 11-07-04 01:36 PM, Stephen Hemminger wrote:
> > Any data about the type of connection, kernel configuration or other
> > information that might be useful in reproducing the problem?
> > 
> > Also please try 2.6.39.2
> 
> We haven't found a sure way of reproducing it.
> It happened on 1.2% of our servers over the weekend and seems random.
> Both are connected with 2 gigabit ports using bonding. Traffic tends to
> be heavy, but doesn't seem to be a factor.
> 
> Would a .config help ?
> 
> Only the very basic filter module for iptables is compiled in.
> 
> We will try 2.6.39.2 soon

Kernel config (and compiler version) would help in identifying which
of the three divides is getting divide by zero.
