From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Introduce possible_net_t
Date: Thu, 12 Mar 2015 14:40:15 -0400 (EDT)
Message-ID: <20150312.144015.420979058716247691.davem@davemloft.net>
References: <1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150311.232940.1345045254716776224.davem@davemloft.net>
	<87oany7tha.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, salo@google.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbbCLSkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:40:17 -0400
In-Reply-To: <87oany7tha.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 11 Mar 2015 23:03:13 -0500

> The current usage of write_pnet and read_pnet is a little laborious and
> error prone as you only notice if you failed to include them if are
> compiling with network namespaces enabled.
> 
> possible_net_t remedies that by using a type that is 0 bytes when
> network namespaces are disabled and can only be read and written to with
> read_pnet and write_pnet.
> 
> Aka less work and safer for the same effect.
> 
> I kill hold_net and release_net first as are they are haven't been used
> since 2008 and are noise at the points where write_pnet and read_pnet
> are used.
> 
> I have folded in Eric Dumazets suggestions to improve the killing of
> hold_net and release net.  And respon.  I had to respin anyway as
> there was enough changes elsewhere in the tree the previous version
> of these patches did not quite apply cleanly.

Series applied, thanks!
