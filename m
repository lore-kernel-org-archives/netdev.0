From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Wed, 02 Mar 2016 14:52:04 -0500 (EST)
Message-ID: <20160302.145204.1321971452365441235.davem@davemloft.net>
References: <1456348375-24684-1-git-send-email-bro.devel+kernel@gmail.com>
	<1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
	<1456348375-24684-3-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ycheng@google.com, eric.dumazet@gmail.com,
	ncardwell@google.com, apetlund@simula.no, griff@simula.no,
	paalh@simula.no, jonassm@ifi.uio.no, kristian.evensen@gmail.com,
	kennetkl@ifi.uio.no
To: bro.devel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbcCBTwH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:52:07 -0500
In-Reply-To: <1456348375-24684-3-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Bendik R=F8nning Opstad" <bro.devel@gmail.com>
Date: Wed, 24 Feb 2016 22:12:55 +0100

> +/* tcp_rdb.c */
> +void rdb_ack_event(struct sock *sk, u32 flags);

Please name globally visible symbols with a prefix of "tcp_*", thanks.
