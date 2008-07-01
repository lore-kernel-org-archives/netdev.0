From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 0/3] Add support for rx flow hash configuration in a network device
Date: Mon, 30 Jun 2008 20:33:45 -0700
Message-ID: <adaabh2ffc6.fsf@cisco.com>
References: <48658078.8030707@Sun.COM> <871w2gph8r.fsf@basil.nowhere.org>
	<20080629.134936.139001500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, Santwona.Behera@Sun.COM,
	netdev@vger.kernel.org, jeff@garzik.org, Matheos.Worku@Sun.COM,
	Michael.Speer@Sun.COM, gkernel-commit@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:17540 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbYGADeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 23:34:06 -0400
In-Reply-To: <20080629.134936.139001500.davem@davemloft.net> (David Miller's
	message of "Sun, 29 Jun 2008 13:49:36 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > We've discussed this before and Jeff Garzik and I already told
 > everyone that we want to make this configurable and ethtool is
 > the way to do it no matter how adhoc and device specific the
 > interfaces might end up being.

I think it was a few weeks ago that Jeff said:

  I know user interfaces are annoying because you have to think about 
  chips other than your own, but that's life.  Other hardware vendors have 
  to do it too.

  Letting each driver have a different user interface is /unfriendly/ to 
  both developers users.

I guess as long as you stick an "ethtool" in front of the different
interfaces it all becomes OK.

 - R.
