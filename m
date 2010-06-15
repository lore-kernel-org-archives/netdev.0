From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6 3/3] bridge: use rx_handler_data pointer to
 store net_bridge_port pointer V2
Date: Tue, 15 Jun 2010 18:51:21 +0200
Message-ID: <20100615165121.GB2623@psychotron.redhat.com>
References: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
 <20100610133628.GF2618@psychotron.lab.eng.brq.redhat.com>
 <20100615132833.GB3797@psychotron.lab.eng.brq.redhat.com>
 <20100615093035.6f54c085@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	eric.dumazet@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757922Ab0FOQv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 12:51:28 -0400
Content-Disposition: inline
In-Reply-To: <20100615093035.6f54c085@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 15, 2010 at 06:30:35PM CEST, shemminger@vyatta.com wrote:
>On Tue, 15 Jun 2010 15:28:34 +0200
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
>> index 7805bbf..e7f4703 100644
>> --- a/drivers/net/ksz884x.c
>> +++ b/drivers/net/ksz884x.c
>> @@ -5718,7 +5718,7 @@ static void dev_set_promiscuous(struct net_device *dev, struct dev_priv *priv,
>>  		 * from the bridge.
>>  		 */
>>  		if ((hw->features & STP_SUPPORT) && !promiscuous &&
>> -				dev->br_port) {
>> +		    dev->priv_flags & IFF_BRIDGE_PORT) {
>
>I like this patch except for one thing. The mask here should be surrounded
>by paren's to avoid the possible confusion about && and & in same if
>statement.  The C precedence rules allow this but humans get confused.

Right, reposted.

Thanks for review
