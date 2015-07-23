From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 iproute2] tc: fix bpf compilation with old glibc
Date: Thu, 23 Jul 2015 09:25:13 +0200
Message-ID: <55B096D9.2050806@iogearbox.net>
References: <20150722094702.2eb3c0ea@urahara> <1437635861-19157-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46226 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbbGWHZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 03:25:17 -0400
In-Reply-To: <1437635861-19157-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2015 09:17 AM, Nicolas Dichtel wrote:
> Error was:
> f_bpf.o: In function `bpf_parse_opt':
> f_bpf.c:(.text+0x88f): undefined reference to `secure_getenv'
> m_bpf.o: In function `parse_bpf':
> m_bpf.c:(.text+0x587): undefined reference to `secure_getenv'
> collect2: error: ld returned 1 exit status
>
> There is no special reason to use the secure version of getenv, thus let's
> simply use getenv().
>
> CC: Daniel Borkmann <daniel@iogearbox.net>
> Fixes: 88eea5395483 ("tc: {f,m}_bpf: allow to retrieve uds path from env")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
