From: David Miller <davem@davemloft.net>
Subject: Re: [patch] Re: genetlink misinterprets NEW as GET
Date: Sun, 09 Jan 2011 16:25:33 -0800 (PST)
Message-ID: <20110109.162533.241446494.davem@davemloft.net>
References: <4D266CE5.4000309@netfilter.org>
	<alpine.LNX.2.01.1101071357420.27454@obet.zrqbmnf.qr>
	<4D271614.6000303@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, blp@nicira.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D271614.6000303@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 07 Jan 2011 14:33:08 +0100

> On 07/01/11 14:15, Jan Engelhardt wrote:
>> netlink: test for all flags of the NLM_F_DUMP composite
>> 
>> Due to NLM_F_DUMP is composed of two bits, NLM_F_ROOT | NLM_F_MATCH,
>> when doing "if (x & NLM_F_DUMP)", it tests for _either_ of the bits
>> being set. Because NLM_F_MATCH's value overlaps with NLM_F_EXCL,
>> non-dump requests with NLM_F_EXCL set are mistaken as dump requests.
>> 
>> Substitute the condition to test for _all_ bits being set.
>> 
>> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> 
> Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, and queued up for -stable, thanks guys!
