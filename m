From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 3/3 v4] drivers: net: ethernet: qualcomm: rmnet:
 Initial implementation
Date: Wed, 16 Aug 2017 11:46:48 -0600
Message-ID: <3cff6f8152b3390f0fc137549c72345a@codeaurora.org>
References: <1502856953-30321-1-git-send-email-subashab@codeaurora.org>
 <1502856953-30321-4-git-send-email-subashab@codeaurora.org>
 <20170816113017.GJ1868@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56984 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbdHPRqu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 13:46:50 -0400
In-Reply-To: <20170816113017.GJ1868@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +struct rmnet_phys_ep_conf_s {
> 
> The name is cryptic. Why "_s"?
>> +
>> +struct rmnet_vnd_private_s {
> 
> Again, cryptic.
> 
> 
>> +	struct rmnet_logical_ep_conf_s local_ep;
>> +	u32 msg_enable;
>> +};

Hi Jiri

The _s was to indicate struct. I'll remove that.

>> +rx_handler_result_t rmnet_ingress_handler(struct sk_buff *skb)
>> +{
>> +	struct rmnet_phys_ep_conf_s *config;
> 
> I still fail to understand why the name of this is "config". Please
> change to something else across whole code. Including the name of the 
> struct.
> 
>> +	struct net_device *dev;
>> +	int rc;
>> +
>> +	if (!skb)
>> +		return RX_HANDLER_CONSUMED;
>> +
>> +	dev = skb->dev;
>> +	config = rmnet_get_phys_ep_config(skb->dev);
> 
> You have dev. Why not use dev?
> 
>> +rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
>> +{
>> +	return rmnet_ingress_handler(*pskb);
> 
> This is just silly. Why you don't have the content of 
> rmnet_ingress_handler
> right here?

I'll make these changes now.
