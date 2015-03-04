From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: link failures with bpf_map_xxx_elem_proto calls from net/core/filiter.c
Date: Wed, 04 Mar 2015 07:44:35 -0800
Message-ID: <54F72863.6090905@plumgrid.com>
References: <54F6C55C.9090400@mellanox.com> <54F6C8D2.3080007@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:43015 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758575AbbCDPog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 10:44:36 -0500
Received: by iecrp18 with SMTP id rp18so315524iec.10
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 07:44:35 -0800 (PST)
In-Reply-To: <54F6C8D2.3080007@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/15 12:56 AM, Or Gerlitz wrote:
> On 3/4/2015 10:42 AM, Or Gerlitz wrote:
>> Hi Daniel,
>>
>> With net-next (and probably net or Linus tree too), I am getting these
>> link failures
>>
>> net/built-in.o:(.rodata+0x2210): undefined reference to
>> `bpf_map_lookup_elem_proto'
>> net/built-in.o:(.rodata+0x2218): undefined reference to
>> `bpf_map_update_elem_proto'
>> net/built-in.o:(.rodata+0x2220): undefined reference to
>> `bpf_map_delete_elem_proto'
>>
>
> suddenly solved after make clean and make, probably a leftover from the
> fact that net-next was rebased tonight from 3.19 to 4.0-rc2

that actually a real issue and Daniel has a patch that fixes it.
Will be submitted soon.
