From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vxlan: set mac_header correctly in GPE mode
Date: Mon, 16 May 2016 13:38:47 -0400 (EDT)
Message-ID: <20160516.133847.1906083294466783910.davem@davemloft.net>
References: <2f5ecda4984940c2c6820cbbed18555d5023e2ed.1463129287.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	shmulik.ladkani@gmail.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbcEPRi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:38:58 -0400
In-Reply-To: <2f5ecda4984940c2c6820cbbed18555d5023e2ed.1463129287.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 13 May 2016 10:48:42 +0200

> For VXLAN-GPE, the interface is ARPHRD_NONE, thus we need to reset
> mac_header after pulling the outer header.
> 
> v2: Put the code to the existing conditional block as suggested by
>     Shmulik Ladkani.
> 
> Fixes: e1e5314de08b ("vxlan: implement GPE")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
