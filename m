From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2] filter: introduce SKF_AD_VLAN_TPID BPF extension
Date: Sat, 21 Mar 2015 08:41:17 -0700
Message-ID: <550D911D.9070604@plumgrid.com>
References: <1426763414-10091-1-git-send-email-msekleta@redhat.com> <550AF483.8040202@plumgrid.com> <20150320102718.GB30812@morgoth.brq.redhat.com> <550CD62C.7080105@plumgrid.com> <550D3EBF.4000907@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38315 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbbCUPlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 11:41:18 -0400
Received: by igbqf9 with SMTP id qf9so9856603igb.1
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 08:41:17 -0700 (PDT)
In-Reply-To: <550D3EBF.4000907@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/21/15 2:49 AM, Daniel Borkmann wrote:
> On 03/21/2015 03:23 AM, Alexei Starovoitov wrote:
>> On 3/20/15 3:27 AM, Michal Sekletar wrote:
>>> On Thu, Mar 19, 2015 at 09:08:35AM -0700, Alexei Starovoitov wrote:
>>>> Since it's a new field, I think it makes sense not to do ntohs at all.
>>>> Let bpf programs do htons(PROTO_CONSTANT), since it can be done at
>>>> compile time instead of run-time.
>>>
>>> Doing htons is not needed for vlan_tci thus I wanted to avoid
>>> surprise for
>>> users. But of course I'll do whatever you think is the best.
>>
>> ok. then let's not add ntohs for vlan_tpid
>
> Why? What speaks against handling this the exact same way as we
> do now with skb->protocol?

hmm. I think you miss read it. It's exactly the same way as
skb->protocol for extended. No point doing it differently for classic.
