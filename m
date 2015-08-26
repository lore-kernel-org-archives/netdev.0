From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: sched: consolidate tc_classify{,_compat}
Date: Thu, 27 Aug 2015 00:02:30 +0200
Message-ID: <55DE3776.2060700@iogearbox.net>
References: <3dfe133299d033dfa52bcf63d846f3f91b56d30c.1440620622.git.daniel@iogearbox.net> <55DE357D.7010800@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37354 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbbHZWCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:02:34 -0400
In-Reply-To: <55DE357D.7010800@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 11:54 PM, Alexei Starovoitov wrote:
> On 8/26/15 2:00 PM, Daniel Borkmann wrote:
...
>> +reset:
>> +    if (unlikely(limit++ >= MAX_REC_LOOP)) {
>> +        net_notice_ratelimited("%s: reclassify loop, rule prio %u, "
>> +                       "protocol %02x\n", tp->q->ops->id,
>> +                       tp->prio & 0xffff, ntohs(tp->protocol));
>
> why drop 'packet' and add two extra ',' in the message ?
> Not a big deal, just why bother?

No deep underlying reason, thought it would make it slightly
more readable.
