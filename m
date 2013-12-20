From: Valentina Giusti <valentina.giusti@bmw-carit.de>
Subject: Re: [PATCH v3 1/2] netfilter_queue: enable UID/GID socket info retrieval
Date: Fri, 20 Dec 2013 16:10:18 +0100
Message-ID: <52B45DDA.5050504@bmw-carit.de>
References: <1387542820-16319-1-git-send-email-valentina.giusti@bmw-carit.de> <1387542820-16319-2-git-send-email-valentina.giusti@bmw-carit.de> <20131220140959.GA29632@breakpoint.cc> <52B45504.20608@bmw-carit.de> <20131220150324.GB29632@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jpa@google.com>, <pablo@netfilter.org>,
	<daniel.wagner@bmw-carit.de>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bmw-carit.de ([62.245.222.98]:33000 "EHLO
	mail.bmw-carit.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441Ab3LTPKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 10:10:31 -0500
In-Reply-To: <20131220150324.GB29632@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 04:03 PM, Florian Westphal wrote:
> Valentina Giusti <valentina.giusti@bmw-carit.de> wrote:
>>> I think this should be 'return 0'?
>> I put return -1 because I think that if userspace has requested to
>> receive UID and GID, then it should be dumped only packets that have
>> that information available.
>> Are you suggesting that it should be otherwise?
>
> Yes, doing that doesn't make sense to me.
> And it is inconsitent:
> Packets without socket information are queued normally
> in your patch, but suddently if its a timewait socket
> its an error?
>
> Why would we want timewait packets to NOT be queued?
> vs. for example forwarded packets?
>
> Userspace can test for presence of the attributes, i.e.
> no NFQA_UID attribute -> no socket present, or lack of uid
> information.
>
> If you have a counter-example?
>

Sorry no, I think you are right, thanks for the explanation. Should I 
resend the patch or is it a change small enough that can be done when 
applied? Unless there are still other comments, ofc.

Thanks,
- Val
