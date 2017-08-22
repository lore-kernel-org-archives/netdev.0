From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/3 v7] net: ether: Add support for multiplexing
 and aggregation type
Date: Mon, 21 Aug 2017 23:27:13 -0600
Message-ID: <8e0f6382e5770bb32efa342b1fe5cc81@codeaurora.org>
References: <1503355019-12236-1-git-send-email-subashab@codeaurora.org>
 <1503355019-12236-2-git-send-email-subashab@codeaurora.org>
 <20170822010208.GA24555@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@aculab.com,
        marcel@holtmann.org, netdev-owner@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41546 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751087AbdHVF1O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 01:27:14 -0400
In-Reply-To: <20170822010208.GA24555@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +#define ETH_P_MAP       0xDA1A          /* Multiplexing and 
>> Aggregation Protocol
>> +					 *  NOT AN OFFICIALLY REGISTERED ID ]
>> +					 */
> 
> Hi Subash
> 
> This list is sorted. So this entry should go earlier.
> 
>> +	netdev_info(real_dev, "Removed from rmnet\n");
> 
> I would probably turn all your netdev_info()s into netdev_dbg()s.  You
> seem to be spamming the kernel log quite a bit.
> 

Hi Andrew

I'll make these changes and post v8.
