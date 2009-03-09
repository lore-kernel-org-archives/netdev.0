From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] macvlan:  Deterministic ingress packet delivery
Date: Mon, 09 Mar 2009 14:25:11 +0100
Message-ID: <49B518B7.7030409@trash.net>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>	<m1sklqohw2.fsf@fess.ebiederm.org> <49B13259.9040701@trash.net>	<m14oy6n15y.fsf@fess.ebiederm.org> <49B13C7D.10308@trash.net>	<m1bpsellmv.fsf@fess.ebiederm.org> <49B15865.10103@candelatech.com> <m1wsb2h0ew.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44332 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbZCINZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 09:25:18 -0400
In-Reply-To: <m1wsb2h0ew.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
>>From 22d0a3e4ffa91f85c224d171ed7cc2d64a6dda00 Mon Sep 17 00:00:00 2001
> From: Eric Biederman <ebiederm@xmission.com>
> Date: Fri, 6 Mar 2009 09:16:30 -0800
> Subject: 
> 
> Changing the mac address when a macvlan device is up will leave the
> device on the wrong hash chain making it impossible to receive
> packets.
> 
> There is no checking of the mac address set on the macvlan.  Allowing
> a misconfiguration to grab packets from the the underlying device or
> another macvlan.
> 
> To resolve these problems I update the hash table of macvlans when the
> mac address of a macvlan changes, and when updating the hash table
> I verify that the new mac address is usable.
> 
> The result is well defined and predictable if not perfect handling of
> mac vlan mac addresses.
> 
> To keep the code clear I have created a set of hash table maintenance
> in macvlan so I am not open coding the hash function and the logic
> needed to update the hash table all over the place.

This looks fine, thanks.

Acked-by: Patrick McHardy <kaber@trash.net>
