From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: link failures with bpf_map_xxx_elem_proto calls from net/core/filiter.c
Date: Thu, 05 Mar 2015 20:04:05 +0100
Message-ID: <54F8A8A5.8080309@iogearbox.net>
References: <54F6C55C.9090400@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1256; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54361 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbbCETEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 14:04:07 -0500
In-Reply-To: <54F6C55C.9090400@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2015 09:42 AM, Or Gerlitz wrote:
> Hi Daniel,
>
> With net-next (and probably net or Linus tree too), I am getting these link failures
>
> net/built-in.o:(.rodata+0x2210): undefined reference to `bpf_map_lookup_elem_proto'
> net/built-in.o:(.rodata+0x2218): undefined reference to `bpf_map_update_elem_proto'
> net/built-in.o:(.rodata+0x2220): undefined reference to `bpf_map_delete_elem_proto'
>
> which are resolved when CONFIG_BPF_SYSCALL is added to the kernel config, I see now t hat this 4.0-rc1 commit d4052c4aea0cf "ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code" removed the ifdefing, not sure what does "BPF internal header can deal with it" means.

Sorry, I was travelling whole day yesterday.

Will send out a patch today.

Thanks,
Daniel
