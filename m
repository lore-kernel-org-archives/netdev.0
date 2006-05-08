From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netdev: hotplug napi race cleanup
Date: Mon, 08 May 2006 11:37:31 -0700 (PDT)
Message-ID: <20060508.113731.97080992.davem@davemloft.net>
References: <20060424152341.094b72d8@localhost.localdomain>
	<20060506.180947.35317492.davem@davemloft.net>
	<20060508095458.0debd022@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, patrakov@ums.usu.ru,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55952
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932480AbWEHShj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 14:37:39 -0400
To: shemminger@osdl.org
In-Reply-To: <20060508095458.0debd022@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 8 May 2006 09:54:58 -0700

> The issue is are there network devices that can't sleep during
> register_netdevice?

Oh right, I forgot about that.
