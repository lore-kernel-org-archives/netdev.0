From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Print function name in addition to
 function id
Date: Sat, 29 Oct 2016 15:56:08 -0400 (EDT)
Message-ID: <20161029.155608.910725512368974977.davem@davemloft.net>
References: <67466f1b43b8a586bcf63fa1e5e292ed340d515c.1477560166.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52264 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbcJ2T4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 15:56:11 -0400
In-Reply-To: <67466f1b43b8a586bcf63fa1e5e292ed340d515c.1477560166.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Oct 2016 11:23:51 +0200

> The verifier currently prints raw function ids when printing CALL
> instructions or when complaining:
> 
> 	5: (85) call 23
> 	unknown func 23
> 
> print a meaningful function name instead:
> 
> 	5: (85) call bpf_redirect#23
> 	unknown func bpf_redirect#23
> 
> Moves the function documentation to a single comment and renames all
> helpers names in the list to conform to the bpf_ prefix notation so
> they can be greped in the kernel source.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied.
