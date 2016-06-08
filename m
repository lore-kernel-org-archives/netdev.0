From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] l2tp: fix configuration passed to
 setup_udp_tunnel_sock()
Date: Wed, 08 Jun 2016 11:12:34 -0700 (PDT)
Message-ID: <20160608.111234.1806433196448343755.davem@davemloft.net>
References: <330c38fb18cbe52932e6b4b29cca748f29191fab.1465383438.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161092AbcFHSMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:12:36 -0400
In-Reply-To: <330c38fb18cbe52932e6b4b29cca748f29191fab.1465383438.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 8 Jun 2016 12:59:17 +0200

> Unused fields of udp_cfg must be all zeros. Otherwise
> setup_udp_tunnel_sock() fills ->gro_receive and ->gro_complete
> callbacks with garbage, eventually resulting in panic when used by
> udp_gro_receive().
 ...
> v2: use empty initialiser instead of "{ NULL }" to avoid relying on
>     first field's type.
> 
> Fixes: 38fd2af24fcf ("udp: Add socket based GRO and config")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
