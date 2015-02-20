From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] rhashtable: ensure cache line alignment on bucket_table
Date: Fri, 20 Feb 2015 15:53:28 +0100
Message-ID: <54E74A68.9080801@iogearbox.net>
References: <1424443737.5565.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48520 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbBTOxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:53:33 -0500
In-Reply-To: <1424443737.5565.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2015 03:48 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> struct bucket_table contains mostly read fields :
>
> size, locks_mask, locks.
>
> Make sure these are not sharing a cache line with buckets[]
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
