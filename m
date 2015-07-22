From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc: fix bpf compilation with old glibc
Date: Wed, 22 Jul 2015 15:05:32 +0200
Message-ID: <55AF951C.8030106@iogearbox.net>
References: <1437568170-16995-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35961 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933098AbbGVNFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:05:36 -0400
In-Reply-To: <1437568170-16995-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2015 02:29 PM, Nicolas Dichtel wrote:
> Error was:
> f_bpf.o: In function `bpf_parse_opt':
> f_bpf.c:(.text+0x88f): undefined reference to `secure_getenv'
> m_bpf.o: In function `parse_bpf':
> m_bpf.c:(.text+0x587): undefined reference to `secure_getenv'
> collect2: error: ld returned 1 exit status
>
> CC: Daniel Borkmann <daniel@iogearbox.net>
> Fixes: 88eea5395483 ("tc: {f,m}_bpf: allow to retrieve uds path from env")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Thanks Nicolas! I am thinking we should probably just stick to getenv()
and convert these two users.

Thanks,
Daniel
