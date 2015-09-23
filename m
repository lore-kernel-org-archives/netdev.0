From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] sched, bpf: let stack handle !IFF_UP devs on
 bpf_clone_redirect
Date: Wed, 23 Sep 2015 13:55:45 -0700
Message-ID: <560311D1.9020207@plumgrid.com>
References: <a03c9b9daa9f779937fce9f6050a05a2dfeaaeec.1443039304.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35554 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269AbbIWUzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 16:55:54 -0400
Received: by pacfv12 with SMTP id fv12so51206516pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 13:55:54 -0700 (PDT)
In-Reply-To: <a03c9b9daa9f779937fce9f6050a05a2dfeaaeec.1443039304.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 1:20 PM, Daniel Borkmann wrote:
> Similarly as already the case in bpf_redirect()/skb_do_redirect()
> pair, let the stack deal with devs that are !IFF_UP.
>
> dev_forward_skb() as well as dev_queue_xmit() will free the skb
> and increment drop counter internally in such cases, so we can
> spare the condition in bpf_clone_redirect().
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

thanks. was about to send the same fix.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
