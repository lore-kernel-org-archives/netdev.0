From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 3/3 v5] drivers: net: ethernet: qualcomm: rmnet:
 Initial implementation
Date: Mon, 21 Aug 2017 23:34:07 -0600
Message-ID: <189aff978eef108edaf9872c50f1f19f@codeaurora.org>
References: <1502931307-517-1-git-send-email-subashab@codeaurora.org>
 <1502931307-517-4-git-send-email-subashab@codeaurora.org>
 <20170821210853.4b1a150d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        David.Laight@aculab.com, marcel@holtmann.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45320 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdHVFeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 01:34:08 -0400
In-Reply-To: <20170821210853.4b1a150d@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +	priv = netdev_priv(rmnet_dev);
>> +	memset(priv, 0, sizeof(struct rmnet_priv));
> 
> Netdev private area is always zero on creation. See alloc_netdev().
> 
>> +	if (!rmnet_dev)
>> +		return 0;
> 
> Do not confuse 0 with NULL. Did you run sparse?
> 
>> +
>> +	priv = netdev_priv(rmnet_dev);
>> +	if (!priv)
>> +		return 0;
> 
> 
> netdev_priv() always returns a non-NULL value.  The private area is 
> just
> a constant offset below the original network_device structure.

Hi Stephen

I havent used sparse till now. I'll fix the errors reported by it as 
well
your other comments and post again.
