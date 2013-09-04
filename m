From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Optimize vxlan rcv
Date: Wed, 04 Sep 2013 14:42:43 -0400 (EDT)
Message-ID: <20130904.144243.2243750034713846459.davem@davemloft.net>
References: <1378226684-7751-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236Ab3IDSmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:42:44 -0400
In-Reply-To: <1378226684-7751-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue,  3 Sep 2013 09:44:44 -0700

> vxlan-udp-recv function lookup vxlan_sock struct on every packet
> recv by using udp-port number. we can use sk->sk_user_data to
> store vxlan_sock and avoid lookup.
> I have open coded rcu-api to store and read vxlan_sock from
> sk_user_data to avoid sparse warning as sk_user_data is not
> __rcu pointer.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
