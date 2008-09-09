From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours: ip6_dst_lookup_tail NULL crash
Date: Tue, 9 Sep 2008 18:31:05 +0400
Message-ID: <20080909143105.GA24239@2ka.mipt.ru>
References: <20080831111304.d57b9f5a.akpm@linux-foundation.org> <20080907181109.GA2466@2ka.mipt.ru> <200809072119.50307.rdenis@simphalempin.com> <20080908.131547.26037628.davem@davemloft.net> <20080909113215.GB5991@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rdenis@simphalempin.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39148 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753390AbYIIOcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 10:32:51 -0400
Content-Disposition: inline
In-Reply-To: <20080909113215.GB5991@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Sep 09, 2008 at 07:32:15AM -0400, Neil Horman (nhorman@tuxdriver.com) wrote:
> +	/*
> +	 * Here if the dst entry we've looked up
> +	 * has a neighbour entry that is in the INCOMPLETE
> +	 * state and the src address from the flow is
> +	 * marked as OPTIMISTIC, we release the found
> +	 * dst entry and replace it instead with the
> +	 * dst entry of the nexthop router
> +	 */
> +	if (dst->neighbour && !((*dst)->neighbour->nud_state & NUD_VALID)) {
            ^^^
This should be (*dst)->neighbour, isn't it?

-- 
	Evgeniy Polyakov
