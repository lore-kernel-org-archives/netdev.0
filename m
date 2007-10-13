From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Bonding support for eth1394?
Date: Sat, 13 Oct 2007 08:34:44 -0700
Message-ID: <adair5bm3jf.fsf@cisco.com>
References: <FFB081ED-646B-489D-8836-FBA619A57E3E@gmail.com>
	<47106EDE.1090601@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karl Svec <karlsvec@gmail.com>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:25202 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbXJMPeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 11:34:46 -0400
In-Reply-To: <47106EDE.1090601@s5r6.in-berlin.de> (Stefan Richter's message of "Sat, 13 Oct 2007 09:08:14 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > The bonding sources have a few occurrences of EOPNOTSUPP.  Unless I
 > missed something, they are all related to setting the hardware address
 > of the interface.  AFAICS this is impossible with IP over FireWire.  If
 > it is crucial to bonding to be able to change the slaves' hardware
 > addresses, then you are out of luck.

There are a few changes to the bonding driver pending that will add
support for bonding IP-over-InfiniBand interfaces.  IPoIB also cannot
change its HW address, so the patches address that issue.

Once those patches land, bonding eth1394 interfaces may "just work".

 - R.
