From: David Miller <davem@davemloft.net>
Subject: Re: [r8169] About the "PHY reset until link up" warning
Date: Mon, 22 Jul 2013 14:48:50 -0700 (PDT)
Message-ID: <20130722.144850.493762080108085770.davem@davemloft.net>
References: <2215813.0syAhGCZsc@al>
	<20130722214358.GA4997@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org, nic_swsd@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933511Ab3GVVsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 17:48:50 -0400
In-Reply-To: <20130722214358.GA4997@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 22 Jul 2013 23:43:58 +0200

> I can change my mind but I haven't seen much need for a policy
> change yet.

In every case where this issue has popped up, we have decided that
printing messages when the cable is simply unplugged is very
undesirable.

I used to print messages on link failure in all the early drivers I
wrote, it was a bad decision.
