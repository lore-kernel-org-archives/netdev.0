From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/5] stmmac: add CHAINED descriptor mode support (V2)
Date: Thu, 13 Oct 2011 16:39:46 -0400 (EDT)
Message-ID: <20111013.163946.859494070937160730.davem@davemloft.net>
References: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
	<1318426688-9419-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405Ab1JMUjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 16:39:53 -0400
In-Reply-To: <1318426688-9419-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 12 Oct 2011 15:38:04 +0200

> +#if defined(CONFIG_STMMAC_RING)
> +
> +static unsigned int stmmac_jumbo_frm(struct stmmac_priv *priv,
> +				     struct sk_buff *skb, int csum_insertion)
> +{

This is not exactly what I meant.

In your original patch, two or three line snippets of code were conditionalized.

That's what I wanted you to do here.  Keep as much common code around as possible
in the driver *.c file, but the small 2 or 3 line conditional parts are implemented
in very small well contained inline functions implemented in a header file.

These small, 2 or 3 line, inline functions are where the ifdefs go.

I didn't mean to replicate all of the functions, in their entirety, into some
header file.

You might was well put the entire driver into a header file, then you can add
all the ifdefs you want :-)
