From: Kazunori MIAZAWA <kazunori@miyazawa.org>
Subject: Re: (usagi-core 34069) Re: [IPSEC]: Do xfrm_state_check_space before
 encapsulation
Date: Wed, 19 Dec 2007 22:23:01 +0900
Message-ID: <47691B35.5090209@miyazawa.org>
References: <4768A7CA.4090503@taca.jp>	<20071219061210.GA6731@gondor.apana.org.au> <20071218.221456.49781139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, miyazawa@taca.jp,
	netdev@vger.kernel.org
To: usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:55716 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751687AbXLSNXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 08:23:32 -0500
In-Reply-To: <20071218.221456.49781139.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 19 Dec 2007 14:12:10 +0800
> 
>> [IPSEC]: Do xfrm_state_check_space before encapsulation
>>
>> While merging the IPsec output path I moved the encapsulation output
>> operation to the top of the loop so that it sits outside of the locked
>> section.  Unfortunately in doing so it now sits in front of the space
>> check as well which could be a fatal error.
>>
>> This patch rearranges the calls so that the space check happens as
>> the thing on the output path.
>>
>> This patch also fixes an incorrect goto should the encapsulation output
>> fail.
>>
>> Thanks to Kazunori MIYAZAWA for finding this bug.
>>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied, thanks Herbert.
> 
> 

Thank you for your quick response :-)

--
Kazunori Miyazawa

