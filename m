From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] ebpf: include perf_event only where really
 needed
Date: Fri, 2 Oct 2015 09:44:28 -0700
Message-ID: <560EB46C.7050907@plumgrid.com>
References: <1e7712d4d7b8638ad96ca74436fe96508ce89dfa.1443802548.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kaixu Xia <xiakaixu@huawei.com>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34456 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbbJBQo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 12:44:27 -0400
Received: by padhy16 with SMTP id hy16so110947963pad.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 09:44:27 -0700 (PDT)
In-Reply-To: <1e7712d4d7b8638ad96ca74436fe96508ce89dfa.1443802548.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/15 9:42 AM, Daniel Borkmann wrote:
> Commit ea317b267e9d ("bpf: Add new bpf map type to store the pointer
> to struct perf_event") added perf_event.h to the main eBPF header, so
> it gets included for all users. perf_event.h is actually only needed
> from array map side, so lets sanitize this a bit.
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
> Cc: Kaixu Xia<xiakaixu@huawei.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
