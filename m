From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: Need to call bpf_prog_uncharge_memlock from
 bpf_prog_put
Date: Wed, 14 Oct 2015 14:51:00 -0700
Message-ID: <561ECE44.6070109@plumgrid.com>
References: <1444858844-883196-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36022 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbbJNVvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 17:51:03 -0400
Received: by pabws5 with SMTP id ws5so1507639pab.3
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 14:51:02 -0700 (PDT)
In-Reply-To: <1444858844-883196-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/15 2:40 PM, Tom Herbert wrote:
> Currently, is only called from __prog_put_rcu in the bpf_prog_release
> path. Need this to call this from bpf_prog_put also to get correct
> accounting.
>
> Fixes: commit aaac3ba95e4c8b49 ("bpf: charge user for creation of BPF maps and programs")
> Signed-off-by: Tom Herbert<tom@herbertland.com>

ohh. right. good catch. thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
