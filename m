From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Deterministic ingress packet delivery
Date: Fri, 13 Mar 2009 13:16:20 -0700 (PDT)
Message-ID: <20090313.131620.132679618.davem@davemloft.net>
References: <49B15865.10103@candelatech.com>
	<m1wsb2h0ew.fsf_-_@fess.ebiederm.org>
	<49B518B7.7030409@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, greearb@candelatech.com,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44671
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751917AbZCMUQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 16:16:34 -0400
In-Reply-To: <49B518B7.7030409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 09 Mar 2009 14:25:11 +0100

> Eric W. Biederman wrote:
> >>From 22d0a3e4ffa91f85c224d171ed7cc2d64a6dda00 Mon Sep 17 00:00:00 2001
> > From: Eric Biederman <ebiederm@xmission.com>
> > Date: Fri, 6 Mar 2009 09:16:30 -0800
> > Subject: Changing the mac address when a macvlan device is up will leave the
> > device on the wrong hash chain making it impossible to receive
> > packets.
> > There is no checking of the mac address set on the macvlan.  Allowing
> > a misconfiguration to grab packets from the the underlying device or
> > another macvlan.
> > To resolve these problems I update the hash table of macvlans when the
> > mac address of a macvlan changes, and when updating the hash table
> > I verify that the new mac address is usable.
> > The result is well defined and predictable if not perfect handling of
> > mac vlan mac addresses.
> > To keep the code clear I have created a set of hash table maintenance
> > in macvlan so I am not open coding the hash function and the logic
> > needed to update the hash table all over the place.
> 
> This looks fine, thanks.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Also applied, thanks.
