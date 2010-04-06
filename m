From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] netfilter: xt_TEE: have cloned packet travel through
 Xtables too
Date: Tue, 06 Apr 2010 18:37:33 +0200
Message-ID: <4BBB634D.6050109@trash.net>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-6-git-send-email-jengelh@medozas.de> <4BB47768.1050405@trash.net> <alpine.LSU.2.01.1004011258060.17429@obet.zrqbmnf.qr> <4BB47EEA.4020809@trash.net> <alpine.LSU.2.01.1004011511180.1174@obet.zrqbmnf.qr> <4BB49E10.8080608@trash.net> <alpine.LSU.2.01.1004061814120.13186@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1004061814120.13186@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2010-04-01 15:22, Patrick McHardy wrote:
>>> Or should we be using skb_alloc and copying the data portion over, like 
>>> ipt_REJECT does since v2.6.24-2931-g9ba99b0?
>> I guess pskb_copy() would be most optimal since we can modify
>> the header, but the non-linear area could be shared
> 
> Trying to improve my understanding: when doing skb_pull,
> does the skb->head that is relevant for pskb_copy move?

skb_pull() only changes skb->data.
