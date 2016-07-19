From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH iproute2 -master] bpf: also check elf for official
 e_machine value
Date: Mon, 18 Jul 2016 17:36:45 -0700
Message-ID: <20160719003642.GB45296@ast-mbp.thefacebook.com>
References: <a5dbe0907854c72832f0b0d745eaace921bf879e.1468882622.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36863 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbcGSAgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 20:36:49 -0400
Received: by mail-pa0-f67.google.com with SMTP id ez1so202283pab.3
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 17:36:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <a5dbe0907854c72832f0b0d745eaace921bf879e.1468882622.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 01:09:52AM +0200, Daniel Borkmann wrote:
> Use the official BPF ELF e_machine value that was assigned recently [1]
> and will be propagated to glibc, libelf et al. LLVM will switch to it
> in 3.9 release, therefore we need to prepare tc to check for EM_ELF as
> well, older version still have the EM_NONE.
> 
>   [1] https://github.com/llvm-mirror/llvm/commit/36b9c09330bfb5e771914cfe307588f30d5510d2
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Thank you for fixing it.
Acked-by: Alexei Starovoitov <ast@kernel.org>
