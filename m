From: Kazunori MIAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Sat, 08 Mar 2008 23:46:13 +0900
Message-ID: <47D2A6B5.101@miyazawa.org>
References: <20080305213727.35f46f2f.kazunori@miyazawa.org>	<20080305.134020.05696990.davem@davemloft.net>	<47D0E169.5050006@miyazawa.org> <20080306.231947.135681188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:47629 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753722AbYCHOqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2008 09:46:55 -0500
In-Reply-To: <20080306.231947.135681188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> Date: Fri, 07 Mar 2008 15:32:09 +0900
> 
>> David Miller wrote:
>>> I also wonder if the PF_KEY limitation really exists.  For example we
>>> will set x->sel.family etc. from the SADB_EXT_ADDRESS_PROXY attribute
>>> if present.
>>>
>> Yes, we have SADB_EXT_ADDRESS_PROXY. But it is not enough, I think.
>> xfrm_selector has both src and dst so that we need some way to
>> specify the address is src or dst.
>>
>> from RFC2367
> 
> Thank you for this information.
> 
>>> Finally, if the determination can be made in the data path, it
>>> by definition could be made during rule insertion which is much
>>> more efficient and appropriate.
>> I agree with you.
> 
> I am sure there is a simple solution to this problem somewhere,
> it is just hiding :-)
> 

I think one solution is xfrm_state has two inner_modes
and switch them when the family is any.

This is just an idea :-p

--
Kazunori Miyazawa
