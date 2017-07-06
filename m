From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/1] net sched: Added the TC_LINKLAYER_CUSTOM linklayer
 type
Date: Thu, 6 Jul 2017 09:03:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0033CC1@AcuExch.aculab.com>
References: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "McCabe@rockwellcollins.com" <McCabe@rockwellcollins.com>
To: "'McCabe, Robert J'" <Robert.McCabe@rockwellcollins.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:54676 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdGFJDW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 05:03:22 -0400
In-Reply-To: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: McCabe, Robert J
> Sent: 04 July 2017 01:14
> +	if (nla_put(skb, TCA_STAB_DATA, sizeof(stab->szopts)*sizeof(u16), &stab->data))
> +		goto nla_put_failure;

Multiplying sizeof(a) by sizeof(b) really doesn't look right at all.

	David
