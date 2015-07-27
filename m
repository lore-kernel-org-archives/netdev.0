From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: fix bpf compilation with old glibc
Date: Mon, 27 Jul 2015 14:36:28 -0700
Message-ID: <20150727143628.52d46f8d@urahara>
References: <1437568170-16995-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33300 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbbG0VgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:36:19 -0400
Received: by padck2 with SMTP id ck2so57518830pad.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:36:18 -0700 (PDT)
In-Reply-To: <1437568170-16995-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jul 2015 14:29:30 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

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

Applied thanks.
