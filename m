From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] fib_trie: Only display main table in /proc/net/route
Date: Wed, 11 Mar 2015 18:36:14 -0700
Message-ID: <5500ED8E.2080507@gmail.com>
References: <20150311233536.1696.1657.stgit@ahduyck-vm-fedora20> <20150311.212228.1581184934531828534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:36325 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbbCLBgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:36:23 -0400
Received: by iegc3 with SMTP id c3so8588309ieg.3
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 18:36:20 -0700 (PDT)
In-Reply-To: <20150311.212228.1581184934531828534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2015 06:22 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Wed, 11 Mar 2015 16:36:08 -0700
>
>> When we merged the tries for local and main I had overlooked the iterator
>> for /proc/net/route.  As a result it was outputting both local and main
>> when the two tries were merged.
>>
>> This patch resolves that by only providing output for aliases that are
>> actually in the main trie.  As a result we should go back to the original
>> behavior which I assume will be necessary to maintain legacy support.
>>
>> Fixes: 0ddcf43d5 ("ipv4: FIB Local/MAIN table collapse")
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> Applied, thanks Alex.
>
> Please don't put empty lines between Fixes: tags and the signoffs
> and acks, they belong together.

I'll try to remember that for any other patches.

Thanks.

- Alex
