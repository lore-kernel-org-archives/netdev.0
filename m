From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3 v6] net: ether: Add support for
 multiplexing and aggregation type
Date: Sun, 20 Aug 2017 15:12:07 -0700 (PDT)
Message-ID: <20170820.151207.1229905735989482121.davem@davemloft.net>
References: <1503120931-30092-1-git-send-email-subashab@codeaurora.org>
        <1503120931-30092-2-git-send-email-subashab@codeaurora.org>
        <6dd2e0b7-51ec-18a3-07fb-3952a114b89a@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, netdev@vger.kernel.org,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753335AbdHTWMK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 18:12:10 -0400
In-Reply-To: <6dd2e0b7-51ec-18a3-07fb-3952a114b89a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 20 Aug 2017 14:18:03 -0400

> On 17-08-19 01:35 AM, Subash Abhinov Kasiviswanathan wrote:
>> Define the multiplexing and aggregation (MAP) ether type 0xDA1A. This
>> is needed for receiving data in the MAP protocol like RMNET. This is
>> not an officially registered ID.
>> Signed-off-by: Subash Abhinov Kasiviswanathan
>> <subashab@codeaurora.org>
>> ---
>>   include/uapi/linux/if_ether.h | 4 +++-
>>   1 file changed, 3 insertions(+), 1 deletion(-)
>> diff --git a/include/uapi/linux/if_ether.h
>> b/include/uapi/linux/if_ether.h
>> index 5bc9bfd..e80b03f 100644
>> --- a/include/uapi/linux/if_ether.h
>> +++ b/include/uapi/linux/if_ether.h
>> @@ -104,7 +104,9 @@
>>   #define ETH_P_QINQ3 0x9300 /* deprecated QinQ VLAN [ NOT AN OFFICIALLY
>>   #REGISTERED ID ] */
>>   #define ETH_P_EDSA 0xDADA /* Ethertype DSA [ NOT AN OFFICIALLY
>>   #REGISTERED ID ] */
>>   #define ETH_P_AF_IUCV 0xFBFB /* IBM af_iucv [ NOT AN OFFICIALLY
>>   #REGISTERED ID ] */
>> -
>> +#define ETH_P_MAP 0xDA1A /* Multiplexing and Aggregation Protocol
>> + * NOT AN OFFICIALLY REGISTERED ID ]
> 
> You cant just arbitrarly assign yourself an ethertype.  The IEEE may
> never issue you one - and if they do, it will likely not be the one
> you want i.e above.
> 
> If there is a way for you to make this a config option that is not
> hardcoded to some default value then that would be the best approach
> to take.

This may be a kind of a different situation, these ethertypes exist
only internally in the kernel and never on the wire.

It's just controlling the demux on ethernet receive.

We have several IDs like this, and thus this addition is consistent
with existing practice.
