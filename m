From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix address selection in fib_compute_spec_dst
Date: Thu, 19 Jul 2012 08:31:05 -0700 (PDT)
Message-ID: <20120719.083105.2071478258344388297.davem@davemloft.net>
References: <1342683303-3557-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2GSPbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:31:06 -0400
In-Reply-To: <1342683303-3557-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 19 Jul 2012 10:35:03 +0300

> 	ip_options_compile can be called for forwarded packets,
> make sure the specific-destionation address is a local one as
> specified in RFC 1812, 4.2.2.2 Addresses in Options
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
