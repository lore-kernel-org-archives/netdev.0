From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix order in inet_init failure path.
Date: Wed, 27 Sep 2006 16:33:54 -0700 (PDT)
Message-ID: <20060927.163354.51841900.davem@davemloft.net>
References: <20060926141709.GA19722@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20905
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031249AbWI0Xdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:33:55 -0400
To: okir@suse.de
In-Reply-To: <20060926141709.GA19722@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Kirch <okir@suse.de>
Date: Tue, 26 Sep 2006 16:17:09 +0200

> This is just a minor buglet I came across by accident - when inet_init
> fails to register raw_prot, it jumps to out_unregister_udp_proto which
> should unregister UDP _and_ TCP.
> 
> Signed-off-by: Olaf Kirch <okir@suse.de>

Applied, thanks Olaf.
