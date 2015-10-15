From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: Need to call bpf_prog_uncharge_memlock
 from bpf_prog_put
Date: Thu, 15 Oct 2015 10:42:02 +0200
Message-ID: <561F66DA.7020804@iogearbox.net>
References: <1444858844-883196-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45683 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbbJOImH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 04:42:07 -0400
In-Reply-To: <1444858844-883196-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2015 11:40 PM, Tom Herbert wrote:
> Currently, is only called from __prog_put_rcu in the bpf_prog_release
> path. Need this to call this from bpf_prog_put also to get correct
> accounting.
>
> Fixes: commit aaac3ba95e4c8b49 ("bpf: charge user for creation of BPF maps and programs")

Btw, "commit" should not be part of the Fixes tag (see SubmittingPatches +187).

> Signed-off-by: Tom Herbert <tom@herbertland.com>

Fix looks good to me, so:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
