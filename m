From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: Fix new EMAC driver for NAPI changes
Date: Tue, 16 Oct 2007 21:16:08 -0400
Message-ID: <47156258.5010800@garzik.org>
References: <1192513250.19073.10.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux.foundation.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47544 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932529AbXJQBQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 21:16:11 -0400
In-Reply-To: <1192513250.19073.10.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> net: Fix new EMAC driver for NAPI changes
> 
> This fixes the new EMAC driver for the NAPI updates. The previous patch
> by Roland Dreier (already applied) to do that doesn't actually work. This
> applies on top of it makes it work on my test Ebony machine.
> 
> This patch depends on "net: Add __napi_sycnhronize() to sync with napi poll"
> posted previously.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
> The old EMAC driver does things a bit differently (doesn't do useful
> locking :-) and seems to work with Roland patch. So I'm not going to
> touch it unless somebody reports me that it has problems

applied


