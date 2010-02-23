From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next 0/7] cxgb4 patches V2
Date: Tue, 23 Feb 2010 11:07:29 -0800
Message-ID: <4B842771.9000506@chelsio.com>
References: <1266528256-20873-1-git-send-email-dm@chelsio.com> <20100221.223049.183064491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10047 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756Ab0BWTHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 14:07:33 -0500
In-Reply-To: <20100221.223049.183064491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Dimitris Michailidis <dm@chelsio.com>
> Date: Thu, 18 Feb 2010 13:24:09 -0800
> 
>> This is V2 of the cxgb4 patches.
>>
>> Changes since V1:
>> - Whitespace fixed as well as some additional checkpatch issues.
>> - I removed the CH_* logging wrappers.  I used the new netdev_* in a handful of
>>   places but mostly stayed with the dev_* functions.
>> - I added some comments to describe the register macro scheme.  As a macro
>>   change would involve a rather large number of LOCs I'd really like to avoid
>>   changing them.
> 
> I also told you to not use the non-standard S_*, V_*, etc. register
> naming convention.
> 
> If you repost your driver without addressing all of the review
> feedback you've received thus far, you are wasting people's time
> because they will take time out to review your patches again
> only to find that you've haven't fixed everything you've already
> been made aware of.
> 

Can you please clarify what exactly you want me to change about the macros? 
  I looked at a few other drivers in the tree and I saw shift macros with 
_SHIFT or _SH suffixes, masks tend to have _MASK or _MSK suffixes, etc.  Are 
you asking me basically to change our S_, V_, etc prefixes to _SHIFT, etc 
suffixes or are we talking about some other kind of change?  Please bear 
with me, I am trying to understand what you're asking for exactly.
