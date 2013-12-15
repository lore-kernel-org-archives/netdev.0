From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: revert misguided compiler warning fix on ipv6_exthdrs_len
Date: Sun, 15 Dec 2013 18:23:22 +0100
Message-ID: <20131215172322.GB1715@order.stressinduktion.org>
References: <1386824025-27413-1-git-send-email-hkchu@google.com> <20131214062929.GA23563@order.stressinduktion.org> <20131214.020211.969354536190248209.davem@davemloft.net> <CAPshTCj38XqrAMTKnGhw1bdWWrhHbzXpT8FNtDwd6_kJgLoeDg@mail.gmail.com> <20131215171806.GA1715@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Jerry Chu <hkchu@google.com>, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57095 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688Ab3LORXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 12:23:24 -0500
Content-Disposition: inline
In-Reply-To: <20131215171806.GA1715@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 15, 2013 at 06:18:06PM +0100, Hannes Frederic Sowa wrote:
> This essentlally reverts commit f52d81dc27c3456c702e83183035142c222acdc7
> ("ipv6: fix compiler warning in ipv6_exthdrs_len") and silences the
> warning with uninitialized_var.

David, please discard this. Jerry already posted a nicer cleanup.

Sorry,

  Hannes
