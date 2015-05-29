From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] ss: Fix allocation of cong control alg name
Date: Fri, 29 May 2015 13:11:36 +0200
Message-ID: <55684968.9070206@iogearbox.net>
References: <1432895400-12266-1-git-send-email-vadim4j@gmail.com> <1432897445.7456.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48492 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbbE2LLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 07:11:38 -0400
In-Reply-To: <1432897445.7456.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2015 01:04 PM, Eric Dumazet wrote:
...
> I doubt TCP_CA_NAME_MAX will ever change in the kernel : 16 bytes.
>
> Its typically "cubic" and less than 8 bytes.
>
> Using 8 bytes to point to a malloc(8) is a waste.
>
> Please remove the memory allocation, or store the pointer, since
> tcp_show_info() does the malloc()/free() before return.

+1, much better
