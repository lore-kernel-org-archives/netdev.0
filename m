From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/3] cls_bpf: also dump TCA_BPF_FLAGS
Date: Wed, 23 Sep 2015 13:52:25 -0700
Message-ID: <56031109.9090206@plumgrid.com>
References: <cover.1443037353.git.daniel@iogearbox.net>
 <9e9ae1f3f6412f02ced924132ba5137425f3a699.1443037353.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33195 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905AbbIWUw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 16:52:27 -0400
Received: by pacex6 with SMTP id ex6so50381696pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 13:52:27 -0700 (PDT)
In-Reply-To: <9e9ae1f3f6412f02ced924132ba5137425f3a699.1443037353.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 12:56 PM, Daniel Borkmann wrote:
> In commit 43388da42a49 ("cls_bpf: introduce integrated actions") we
> have added TCA_BPF_FLAGS. We can also retrieve this information from
> the prog, dump it back to user space as well. It's useful in tc when
> displaying/dumping filter info.
>
> Also, remove tp from cls_bpf_prog_from_efd(), came in as a conflict
> from a rebase and it's unused here (later work may add it along with
> a real user).
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
