From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 0/5] SCTP fix/updates
Date: Wed, 30 Oct 2013 10:29:48 -0400
Message-ID: <527117DC.3030400@gmail.com>
References: <1383130252-1515-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:43272 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167Ab3J3O3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 10:29:51 -0400
In-Reply-To: <1383130252-1515-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2013 06:50 AM, Daniel Borkmann wrote:
> Please see patch 5 for the main description/motivation, the rest just
> brings in the needed functionality for that. Although this is actually
> a fix, I've based it against net-next as some additional work for
> fixing it was needed.
>
> Thanks!
>
> Daniel Borkmann (5):
>    lib: crc32: clean up spacing in test cases
>    lib: crc32: add functionality to combine two crc32{,c}s in GF(2)
>    lib: crc32: add test cases for crc32{,c}_combine routines
>    net: skb_checksum: allow custom update/combine for walking skb
>    net: sctp: fix and consolidate SCTP checksumming code
>
>   include/linux/crc32.h       |  40 ++++
>   include/linux/skbuff.h      |  13 +-
>   include/net/checksum.h      |   6 +
>   include/net/sctp/checksum.h |  56 ++----
>   lib/crc32.c                 | 453 +++++++++++++++++++++++++-------------------
>   net/core/skbuff.c           |  31 ++-
>   net/sctp/output.c           |   9 +-
>   7 files changed, 350 insertions(+), 258 deletions(-)
>

Series
Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad
