From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH 3/3] net: TCP thin dupack
Date: Thu, 29 Oct 2009 11:48:55 +0100
Message-ID: <64F26430-3673-4D72-8D09-518DBF6D6438@simula.no>
References: <4AE7207D.8090402@simula.no> <4AE7AFC4.3040805@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:40985 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbZJ2Ksy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:48:54 -0400
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N3SYs-0002px-EM
	for netdev@vger.kernel.org; Thu, 29 Oct 2009 11:48:58 +0100
In-Reply-To: <4AE7AFC4.3040805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Den 28. okt. 2009 kl. 03.43 skrev William Allen Simpson:

> Andreas Petlund wrote:
>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>> index e64368d..f4a05ff 100644
>> --- a/include/linux/tcp.h
>> +++ b/include/linux/tcp.h
>> @@ -97,6 +97,7 @@ enum {
>> #define TCP_CONGESTION		13	/* Congestion control algorithm */
>> #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
>> #define TCP_THIN_RM_EXPB        15      /* Remove exp. backoff for  
>> thin streams*/
>> +#define TCP_THIN_DUPACK         16      /* Fast retrans. after 1  
>> dupack */
>>
> I've not had the chance to examine the rest, but I've been poking at a
> patch series that's used 15 for over a year, so could you try 16 and  
> 17?

Thank you for the feedback. I will address this in the next patch  
iteration.
