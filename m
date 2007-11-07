From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH][PACKET] Remove unneeded packet_socks_nr variable
Date: Wed, 7 Nov 2007 13:50:04 -0200
Message-ID: <20071107155004.GI27345@ghostprotocols.net>
References: <4731DAA3.7060306@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578AbXKGPuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 10:50:13 -0500
Content-Disposition: inline
In-Reply-To: <4731DAA3.7060306@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Nov 07, 2007 at 06:32:51PM +0300, Pavel Emelyanov escreveu:
> This one is used only under ifdef PACKET_REFCNT_DEBUG in
> printk and is not needed otherwise. So hide all this stuff
> under the PACKET_REFCNT_DEBUG.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Look at sk_refcnt_debug_inc, etc and you'll se a more standard way. I
forgot to make this when making all protocol families use sk_prot, even
if just partially :-)

- Arnaldo
