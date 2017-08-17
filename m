From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 2/3 v4] net: arp: Add support for raw IP device
Date: Wed, 16 Aug 2017 18:59:54 -0600
Message-ID: <83c4818e604acea8b908bd74e8dbbfad@codeaurora.org>
References: <1502856953-30321-1-git-send-email-subashab@codeaurora.org>
 <1502856953-30321-3-git-send-email-subashab@codeaurora.org>
 <7D61C5CD-5B75-46C8-AC00-C4852FC1A554@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev list <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, fengguang.wu@intel.com,
        Dan Williams <dcbw@redhat.com>, jiri@resnulli.us,
        stephen@networkplumber.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50310 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdHQA7z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 20:59:55 -0400
In-Reply-To: <7D61C5CD-5B75-46C8-AC00-C4852FC1A554@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
>> index cf73510..d6650e2 100644
>> --- a/include/uapi/linux/if_arp.h
>> +++ b/include/uapi/linux/if_arp.h
>> @@ -59,6 +59,7 @@
>> #define ARPHRD_LAPB	516		/* LAPB				*/
>> #define ARPHRD_DDCMP    517		/* Digital's DDCMP protocol     */
>> #define ARPHRD_RAWHDLC	518		/* Raw HDLC			*/
>> +#define ARPHRD_RAWIP    530             /* Raw IP                     
>>   */
> 
> what is up with gap here?
> 
> Regards
> 
> Marcel

Hi Marcel

I was earlier using that id internally since I was not sure if some 
conflict
could arise there. I have picked 519 for it now.
