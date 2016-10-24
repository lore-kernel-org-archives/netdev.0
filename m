From: Tobias Brunner <tobias@strongswan.org>
Subject: Re: [PATCH net] macsec: Fix header length if SCI is added if
 explicitily disabled
Date: Mon, 24 Oct 2016 15:32:40 +0200
Message-ID: <253edab5-98e6-60e0-0c29-2f1205a4dd1a@strongswan.org>
References: <bfb9f7ef-39b1-269f-48de-d7caf5c54c2f@strongswan.org>
 <20161024112822.GA28497@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80046.hsr.ch ([152.96.80.46]:57924 "EHLO
        mail.strongswan.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934973AbcJXNco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 09:32:44 -0400
In-Reply-To: <20161024112822.GA28497@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [snip]
>> @@ -440,12 +448,12 @@ static void macsec_fill_sectag(struct macsec_eth_header *h,
>>  			       const struct macsec_secy *secy, u32 pn)
>>  {
>>  	const struct macsec_tx_sc *tx_sc = &secy->tx_sc;
>> +	bool sci_present = send_sci(secy);
> 
> You're already computing this in macsec_encrypt() just before calling
> macsec_fill_sectag(), so you could pass it as argument instead of
> recomputing it.

Right, I'll send a v2.  Would you like me to inline the send_sci()
function, as it will only be called once afterwards.

Regards,
Tobias
