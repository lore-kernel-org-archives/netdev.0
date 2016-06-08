From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gue: Implement direction IP encapsulation
Date: Tue, 07 Jun 2016 23:51:56 -0700 (PDT)
Message-ID: <20160607.235156.1959568628820629457.davem@davemloft.net>
References: <1465254362-1321531-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbcFHGv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 02:51:59 -0400
In-Reply-To: <1465254362-1321531-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 6 Jun 2016 16:06:02 -0700

> This patch implements direct encapsulation of IPv4 and IPv6 packets
> in UDP. This is done a version "1" of GUE and as explained in I-D
> draft-ietf-nvo3-gue-03.
> 
> Changes here are only in the receive path, fou with IPxIPx already
> supports the transmit side. Both the normal receive path and
> GRO path are modified to check for GUE version and check for
> IP version in the case that GUE version is "1".
 ...
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, thanks.
