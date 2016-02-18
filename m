From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/3] geneve: Relax MTU constraints
Date: Thu, 18 Feb 2016 15:07:15 -0500 (EST)
Message-ID: <20160218.150715.2026246274939635940.davem@davemloft.net>
References: <86vb5o3kd5.fsf@weave.works>
	<CALx6S37OgkxTLv6XEjFN4T=W8ZdZV_kx4wtPqtVwMizoUXbpVw@mail.gmail.com>
	<86bn7e2c3t.fsf@weave.works>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, jesse@kernel.org, netdev@vger.kernel.org,
	dev@openvswitch.org, hannes@stressinduktion.org, tgraf@suug.ch,
	roopa@cumulusnetworks.com
To: david@weave.works
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425675AbcBRUHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:07:17 -0500
In-Reply-To: <86bn7e2c3t.fsf@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Wragg <david@weave.works>
Date: Thu, 18 Feb 2016 16:54:14 +0000

> Tom Herbert <tom@herbertland.com> writes:
>> Please implement like in ip_tunnel_change_mtu (or better yet call it),
>> that is the precedent for tunnels.
> 
> I've made geneve_change_mtu follow ip_tunnel_change_mtu in v2.
> 
> If it were to call it instead, are you suggesting just passing in
> t_hlen?  Or restructuring geneve.c to re-use the whole ip_tunnel
> infrastructure?
> 
> Also, I'm not sure where the 0xFFF8 comes from in
> __ip_tunnel_change_mtu.  Any ideas why 0xFFF8 rather than 0xffff?  It
> goes all the way back to the inital import of the kernel into git.

Some 8 byte multiple requirement, perhaps to do with fragmentation.
