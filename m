From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netfilter: ctnetlink: support kernel-space dump
 filtering by ctmark
Date: Sun, 26 Feb 2012 14:27:15 -0500 (EST)
Message-ID: <20120226.142715.733545358008638087.davem@davemloft.net>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
	<1330129817-28199-4-git-send-email-pablo@netfilter.org>
	<20120225004150.GA13494@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120225004150.GA13494@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 25 Feb 2012 01:41:50 +0100

> On Sat, Feb 25, 2012 at 01:30:17AM +0100, pablo@netfilter.org wrote:
>> From: Pablo Neira Ayuso <pablo@netfilter.org>
>> 
>> This patch adds CTA_MARK_MASK which, together with CTA_MARK, allows
>> you to selectively send conntrack entries to user-space by
>> returning those that match mark & mask.
>> 
>> With this, we can save cycles in the building and the parsing of
>> the entries that may be later on filtered out in user-space by using
>> the ctmark & mask.
> 
> Minor glitch in this patch. One ifdef was missing that would spot an
> unused variable warning if CONFIG_NF_CONNTRACK_MARK is disabled.
> 
> New patch for ctnetlink attached.

Applied.
