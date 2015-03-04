From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: link failures with bpf_map_xxx_elem_proto calls from net/core/filiter.c
Date: Wed, 4 Mar 2015 10:56:50 +0200
Message-ID: <54F6C8D2.3080007@mellanox.com>
References: <54F6C55C.9090400@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0060.outbound.protection.outlook.com ([157.56.112.60]:32598
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751537AbbCDI6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 03:58:23 -0500
In-Reply-To: <54F6C55C.9090400@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/2015 10:42 AM, Or Gerlitz wrote:
> Hi Daniel,
>
> With net-next (and probably net or Linus tree too), I am getting these 
> link failures
>
> net/built-in.o:(.rodata+0x2210): undefined reference to 
> `bpf_map_lookup_elem_proto'
> net/built-in.o:(.rodata+0x2218): undefined reference to 
> `bpf_map_update_elem_proto'
> net/built-in.o:(.rodata+0x2220): undefined reference to 
> `bpf_map_delete_elem_proto'
>

suddenly solved after make clean and make, probably a leftover from the 
fact that net-next was rebased tonight from 3.19 to 4.0-rc2

Or.
