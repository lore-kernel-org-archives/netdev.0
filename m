From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: link failures with bpf_map_xxx_elem_proto calls from net/core/filiter.c
Date: Thu, 05 Mar 2015 20:06:34 +0100
Message-ID: <54F8A93A.1040700@iogearbox.net>
References: <54F6C55C.9090400@mellanox.com> <54F6C8D2.3080007@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54603 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756589AbbCETGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 14:06:36 -0500
In-Reply-To: <54F6C8D2.3080007@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2015 09:56 AM, Or Gerlitz wrote:
> On 3/4/2015 10:42 AM, Or Gerlitz wrote:
>> Hi Daniel,
>>
>> With net-next (and probably net or Linus tree too), I am getting these link failures
>>
>> net/built-in.o:(.rodata+0x2210): undefined reference to `bpf_map_lookup_elem_proto'
>> net/built-in.o:(.rodata+0x2218): undefined reference to `bpf_map_update_elem_proto'
>> net/built-in.o:(.rodata+0x2220): undefined reference to `bpf_map_delete_elem_proto'
>
> suddenly solved after make clean and make, probably a leftover from the fact that net-next was rebased tonight from 3.19 to 4.0-rc2

Okay, I see. I got a report from Fengguang, he told me that he sees a linker issue only
on avr32 and openrisc archs.

Cooking patch to resolve it ...
