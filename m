From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 11:26:21 -0800
Message-ID: <20160112192620.GB34276@ast-mbp.thefacebook.com>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com>
 <1452626228-15742-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@kernel.org,
	daniel@iogearbox.net, linux-arm-kernel@lists.infradead.org
To: Rabin Vincent <rabin@rab.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36078 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbcALT0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 14:26:24 -0500
Received: by mail-pf0-f171.google.com with SMTP id n128so67438684pfn.3
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 11:26:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452626228-15742-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2016 at 08:17:08PM +0100, Rabin Vincent wrote:
> On ARM64, a BUG() is triggered in the eBPF JIT if a filter with a
> constant shift that can't be encoded in the immediate field of the
> UBFM/SBFM instructions is passed to the JIT.  Since these shifts
> amounts, which are negative or >= regsize, are invalid, reject them in
> the eBPF verifier and the classic BPF filter checker, for all
> architectures.
> 
> Signed-off-by: Rabin Vincent <rabin@rab.in>
> ---
> v2: handle BPF_ARSH too

Thanks.
Acked-by: Alexei Starovoitov <ast@kernel.org>
