From: Joe Perches <joe@perches.com>
Subject: Re: [XFRM]: constify 'struct xfrm_type'
Date: Thu, 24 Jan 2008 09:17:37 -0800
Message-ID: <1201195057.16268.32.camel@localhost>
References: <20080124122621.3248c651.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2002 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbYAXRSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 12:18:34 -0500
In-Reply-To: <20080124122621.3248c651.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-01-24 at 12:26 +0100, Eric Dumazet wrote:
> -	struct xfrm_type *type;
> +	const struct xfrm_type *type;

Perhaps const foo * const bar; for most or all of these
conversions?


