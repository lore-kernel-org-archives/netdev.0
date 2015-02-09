From: Josh Hunt <johunt@akamai.com>
Subject: Re: nft hash set expansion problem
Date: Mon, 09 Feb 2015 09:28:35 -0600
Message-ID: <54D8D223.8040502@akamai.com>
References: <54D7BB53.2050203@akamai.com> <54D7E677.5050708@iogearbox.net> <54D8C7D0.9030803@akamai.com> <20150209152127.GA29739@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:41726 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932490AbbBIP2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 10:28:37 -0500
In-Reply-To: <20150209152127.GA29739@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/2015 09:21 AM, Thomas Graf wrote:
> On 02/09/15 at 08:44am, Josh Hunt wrote:
>> On 02/08/2015 04:43 PM, Daniel Borkmann wrote:
>>> This seems not correct as we want to have an upper limit for
>>> rhashtable expansions. It's better to define a max_shift for
>>> nftables, instead.
>>
>> Thanks Daniel that's what I wanted to know. I'll fix this on the nft_hash
>> side.
>
> I agree it does not make sense to allow unlimited growth.
> Can you enforce a max_shift > 0 in rhashtable_init() while you
> are at it?
>

Yeah I'll do that as well.
