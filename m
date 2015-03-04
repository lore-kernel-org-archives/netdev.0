From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: link failures with bpf_map_xxx_elem_proto calls from net/core/filiter.c
Date: Wed, 4 Mar 2015 10:42:04 +0200
Message-ID: <54F6C55C.9090400@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0099.outbound.protection.outlook.com ([157.55.234.99]:34982
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932903AbbCDIml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 03:42:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

With net-next (and probably net or Linus tree too), I am getting these 
link failures

net/built-in.o:(.rodata+0x2210): undefined reference to 
`bpf_map_lookup_elem_proto'
net/built-in.o:(.rodata+0x2218): undefined reference to 
`bpf_map_update_elem_proto'
net/built-in.o:(.rodata+0x2220): undefined reference to 
`bpf_map_delete_elem_proto'

which are resolved when CONFIG_BPF_SYSCALL is added to the kernel 
config, I see now t hat this 4.0-rc1 commit d4052c4aea0cf "ebpf: remove 
CONFIG_BPF_SYSCALL ifdefs in socket filter code" removed the ifdefing, 
not sure what does "BPF internal header can deal with it" means.

Or.
