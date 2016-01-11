From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/2] bpf: export helper function flags and
 reject invalid ones
Date: Sun, 10 Jan 2016 16:27:18 -0800
Message-ID: <20160111002716.GA21834@ast-mbp.thefacebook.com>
References: <cover.1452385316.git.daniel@iogearbox.net>
 <a948ba8030e453ce04981ac2e532b8a1e708381f.1452385316.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33308 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757441AbcAKA1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 19:27:19 -0500
Received: by mail-pa0-f52.google.com with SMTP id cy9so312429131pac.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 16:27:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <a948ba8030e453ce04981ac2e532b8a1e708381f.1452385316.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 01:16:38AM +0100, Daniel Borkmann wrote:
> Export flags used by eBPF helper functions through UAPI, so they can be
> used by programs (instead of them redefining all flags each time or just
> using the hard-coded values). It also gives a better overview what flags
> are used where and we can further get rid of the extra macros defined in
> filter.c. Moreover, reject invalid flags.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
