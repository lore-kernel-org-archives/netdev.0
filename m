From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v3 0/2] nft hash resize fixes
Date: Tue, 24 Feb 2015 18:35:29 +0100
Message-ID: <54ECB661.9050306@6wind.com>
References: <1424798736-11857-1-git-send-email-johunt@akamai.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Josh Hunt <johunt@akamai.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38899 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbbBXRfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 12:35:32 -0500
Received: by mail-wi0-f177.google.com with SMTP id bs8so26985624wib.4
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 09:35:31 -0800 (PST)
In-Reply-To: <1424798736-11857-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/02/2015 18:25, Josh Hunt a =C3=A9crit :
> v3:
>   * Renames NFT_HASH_MAX_ELEMENTS to NFT_HASH_MAX_BUCKETS
>   * Add Acked-by for Thomas
>
> Josh Hunt (2):
>    rhashtable: require max_shift if grow_decision defined
>    nft_hash: define max_shift rhashtable parameter
Patches should be inverted to avoid breaking bisection.
