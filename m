From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [r8169] About the "PHY reset until link up" warning
Date: Mon, 22 Jul 2013 23:43:58 +0200
Message-ID: <20130722214358.GA4997@electric-eye.fr.zoreil.com>
References: <2215813.0syAhGCZsc@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48137 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932517Ab3GVVoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 17:44:09 -0400
Content-Disposition: inline
In-Reply-To: <2215813.0syAhGCZsc@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> If this is a (hardware) bug workaround, can't it be restricted to that
> specific hardware or removed altogether (perhaps firmware / other updates
> fixed it already?).

It tastes of QA nightmare. It can't be proven safe easily.

Link failure sucks. If nowhere else, I'll play safe, shamanic with the phy
and I want big pesky messages when something goes unusual.

> Otherwise, what about removing this debug message?

It can be disabled with the msglvl option of ethtool.

It should stop after a few seconds if runtime power management is enabled.

I can change my mind but I haven't seen much need for a policy change yet.

-- 
Ueimor
