From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH v2 2/2] nft_hash: define max_shift rhashtable parameter
Date: Tue, 24 Feb 2015 11:03:01 -0600
Message-ID: <54ECAEC5.6040307@akamai.com>
References: <1424794259-30241-1-git-send-email-johunt@akamai.com> <1424794259-30241-3-git-send-email-johunt@akamai.com> <20150224164219.GC21107@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:59572 "EHLO
	prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbbBXRDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 12:03:04 -0500
In-Reply-To: <20150224164219.GC21107@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2015 10:42 AM, Thomas Graf wrote:
> Maybe this should be called .._MAX_BUCKETS instead, the table
> itself does not have a upper nelements limit but will not grow
> above 16M buckets as the comment states correctly already.
>
> After this change:
> Acked-by: Thomas Graf <tgraf@suug.ch>
>

Sure I can change the name to NFT_HASH_MAX_BUCKETS.

Thanks
Josh
