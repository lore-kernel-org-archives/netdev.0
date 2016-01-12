From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 20:35:19 +0100
Message-ID: <56955577.4060905@iogearbox.net>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com> <1452626228-15742-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Rabin Vincent <rabin@rab.in>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56204 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbcALTf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 14:35:27 -0500
In-Reply-To: <1452626228-15742-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2016 08:17 PM, Rabin Vincent wrote:
> On ARM64, a BUG() is triggered in the eBPF JIT if a filter with a
> constant shift that can't be encoded in the immediate field of the
> UBFM/SBFM instructions is passed to the JIT.  Since these shifts
> amounts, which are negative or >= regsize, are invalid, reject them in
> the eBPF verifier and the classic BPF filter checker, for all
> architectures.
>
> Signed-off-by: Rabin Vincent <rabin@rab.in>

Fine with me as well, thanks for following up!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
