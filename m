From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] bpf: fix panic in SO_GET_FILTER with native ebpf
 programs
Date: Fri, 2 Oct 2015 08:04:03 -0700
Message-ID: <560E9CE3.1010302@plumgrid.com>
References: <98ab6d68ec6db39bfa3b1655d228692457861d60.1443779830.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35647 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbbJBPED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 11:04:03 -0400
Received: by pacfv12 with SMTP id fv12so111003221pac.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 08:04:03 -0700 (PDT)
In-Reply-To: <98ab6d68ec6db39bfa3b1655d228692457861d60.1443779830.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/15 3:06 AM, Daniel Borkmann wrote:
> However, sk_get_filter() wasn't updated to test for this at the
> time when eBPF could be attached. Just throw an error to the user
> to indicate that eBPF cannot be dumped over this interface.
> That way, it can also be known that a program_is_  attached (as
> opposed to just return 0), and a different (future) method needs
> to be consulted for a dump.
>
> Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

ouch. Thanks for the fix!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
