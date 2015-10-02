From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 08/12] nfnetlink: use y2038 safe timestamp
Date: Fri, 2 Oct 2015 14:53:55 +0200
Message-ID: <20151002125355.GA31638@salvia>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <1443612402-3000775-9-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48484 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbbJBMrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2015 08:47:05 -0400
Content-Disposition: inline
In-Reply-To: <1443612402-3000775-9-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 01:26:38PM +0200, Arnd Bergmann wrote:
> The __build_packet_message function fills a nfulnl_msg_packet_timestamp
> structure that uses 64-bit seconds and is therefore y2038 safe, but
> it uses an intermediate 'struct timespec' which is not.
> 
> This trivially changes the code to use 'struct timespec64' instead,
> to correct the result on 32-bit architectures.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Cc: netfilter-devel@vger.kernel.org
> Cc: coreteam@netfilter.org

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

BTW, I don't see the patch for nfnetlink_queue and I think I have seen
it in the diffstat from your cover letter.
