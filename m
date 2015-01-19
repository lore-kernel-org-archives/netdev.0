From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] bonding: fix incorrect lacp mux state
 when agg not active
Date: Mon, 19 Jan 2015 15:56:42 -0500 (EST)
Message-ID: <20150119.155642.161549131768663205.davem@davemloft.net>
References: <1421423848-414-4-git-send-email-jtoppins@cumulusnetworks.com>
	<54BD5A53.8050609@redhat.com>
	<54BD6E28.8020705@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com
To: jtoppins@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbbASU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:56:45 -0500
In-Reply-To: <54BD6E28.8020705@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Date: Mon, 19 Jan 2015 15:50:48 -0500

> On 1/19/15 2:26 PM, Nikolay Aleksandrov wrote:
>>> diff --git a/drivers/net/bonding/bond_3ad.c
>>> b/drivers/net/bonding/bond_3ad.c
>>> index e9b706f..52a8772 100644
>>> --- a/drivers/net/bonding/bond_3ad.c
>>> +++ b/drivers/net/bonding/bond_3ad.c
>>> @@ -471,10 +471,13 @@ static void __record_pdu(struct lacpdu *lacpdu,
>>> struct port *port)
>>>   		 * and the port is matched
>>>   		 */
>>>   		if ((port->sm_vars & AD_PORT_MATCHED)
>>> -		    && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION))
>>> + && (lacpdu->actor_state & AD_STATE_SYNCHRONIZATION)) {
>> In net/ it's preferred to have the logical operators at the end of the
>> previous line. It'd be nice if we start fixing these in bond_3ad.c
>> since
>> they're being touched by the patch anyhow.
> 
> Ack, I prefer at the end too. Question, would it be acceptable to do
> the cleanup of the entire bond_3ad.c code in a separate patch? That
> way the fix vs. cleanup is clear.

If you're touching this line, fix it's style in-situ.
