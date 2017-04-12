From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: eBPF - little-endian load instructions?
Date: Wed, 12 Apr 2017 15:02:00 +0200
Message-ID: <1492002120.2855.3.camel@sipsolutions.net>
References: <1491907114.31620.18.camel@sipsolutions.net>
         <58ECB8CF.8040409@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:36448 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751218AbdDLNCH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 09:02:07 -0400
In-Reply-To: <58ECB8CF.8040409@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 13:06 +0200, Daniel Borkmann wrote:
> 
> There are instructions to convert endianess, see __bpf_prog_run(),
> the ALU_END_TO_BE, ALU_END_TO_LE labels for details. There's a
> BPF_ENDIAN() macro used in the test suite and other places.

Are these hooked up to llvm intrinsics or so? If not, can I do that
through some kind of inline asm statement?

In the samples, I only see people doing

#define _htonl __builtin_bswap32

but I'm not even completely convinced that's correct, since it assumes
a little-endian host?

johannes
