From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race
Date: Mon, 4 Jan 2010 16:06:16 -0800
Message-ID: <OF7FCD6D97.5F7C3DD3-ON882576A2.00001FF7-882576A2.00009335@us.ibm.com>
References: <20100104185109.GA2706@sysclose.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35982 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847Ab0AEAGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 19:06:34 -0500
In-Reply-To: <20100104185109.GA2706@sysclose.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For readability, instead of:

        ret = X;
        if (condition)
                goto out;

I prefer:

        if (condition) {
                ret = X;
                goto out;
        }

which makes it clear that ret is for the return and not
some random state change unrelated to the condition.

Otherwise, looks ok to me.

                                        +-DLS

Acked-by: David L Stevens <dlstevens@us.ibm.com>

