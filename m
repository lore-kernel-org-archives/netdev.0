From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] sock, diag: fix panic in sock_diag_put_filterinfo
Date: Wed, 2 Sep 2015 08:03:49 -0700
Message-ID: <55E70FD5.8020107@plumgrid.com>
References: <8824dd0b0b627c5dfdfd767e0e366e3cc8f9505a.1441193159.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33732 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127AbbIBPDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 11:03:54 -0400
Received: by pacex6 with SMTP id ex6so9251115pac.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 08:03:54 -0700 (PDT)
In-Reply-To: <8824dd0b0b627c5dfdfd767e0e366e3cc8f9505a.1441193159.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/2/15 5:00 AM, Daniel Borkmann wrote:
> diag socket's sock_diag_put_filterinfo() dumps classic BPF programs
> upon request to user space (ss -0 -b). However, native eBPF programs
> attached to sockets (SO_ATTACH_BPF) cannot be dumped with this method:
...
> Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

good catch. thanks
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
