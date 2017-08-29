From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/3 v9] net: ether: Add support for multiplexing
 and aggregation type
Date: Mon, 28 Aug 2017 21:00:28 -0600
Message-ID: <c687a1727c0e93ab715ed7daf22aebb8@codeaurora.org>
References: <1503635966-14076-1-git-send-email-subashab@codeaurora.org>
 <1503635966-14076-2-git-send-email-subashab@codeaurora.org>
 <1503958953.20027.5.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@aculab.com,
        marcel@holtmann.org, andrew@lunn.ch
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37430 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdH2DA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 23:00:29 -0400
In-Reply-To: <1503958953.20027.5.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-08-28 16:22, Dan Williams wrote:
> On Thu, 2017-08-24 at 22:39 -0600, Subash Abhinov Kasiviswanathan
> wrote:
>> Define the multiplexing and aggregation (MAP) ether type 0x00F9. This
>> is needed for receiving data in the MAP protocol like RMNET. This is
>> not an officially registered ID.
>> 
>> Signed-off-by: Subash Abhinov Kasiviswanathan <subash
>> +#define ETH_P_MAP	0x00F9		/* Multiplex &
>> aggregation proto*/
> 
> Any chance you could name this QUALCOMM_MAP or something like that?  Or
> at least update the comment to include that fact.
> 
> Dan
> 

Hi Dan

Sure, I can add a comment for it.
