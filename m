From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the arm64
 tree
Date: Tue, 17 May 2016 08:05:11 +0200
Message-ID: <573AB497.2020301@iogearbox.net>
References: <20160517102441.0cfbc192@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yang Shi <yang.shi@linaro.org>,
	Will Deacon <will.deacon@arm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46437 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062AbcEQGFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 02:05:25 -0400
In-Reply-To: <20160517102441.0cfbc192@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2016 02:24 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>    arch/arm64/Kconfig
>
> between commit:
>
>    8ee708792e1c ("arm64: Kconfig: remove redundant HAVE_ARCH_TRANSPARENT_HUGEPAGE definition")
>
> from the arm64 tree and commit:
>
>    6077776b5908 ("bpf: split HAVE_BPF_JIT into cBPF and eBPF variant")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Diff looks good, thanks!
