From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Remove rebundant address family checking
Date: Wed, 7 Aug 2013 12:57:56 +0200
Message-ID: <20130807105756.GI25511@secunet.com>
References: <1375775456-22628-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32823 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932594Ab3HGK6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 06:58:01 -0400
Content-Disposition: inline
In-Reply-To: <1375775456-22628-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 03:50:56PM +0800, Fan Du wrote:
> present_and_same_family has checked addresses family validness for both
> SADB_EXT_ADDRESS_SRC and SADB_EXT_ADDRESS_DST in the beginning.
> Thereafter pfkey_sadb_addr2xfrm_addr doesn't need to do the checking again.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Applied to ipsec-next,

Thanks!
