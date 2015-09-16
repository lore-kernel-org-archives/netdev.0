From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/2] bpf: add bpf_redirect() helper
Date: Tue, 15 Sep 2015 22:08:22 -0700
Message-ID: <55F8F946.7060608@plumgrid.com>
References: <1442368295-5204-1-git-send-email-ast@plumgrid.com>
 <1442368295-5204-3-git-send-email-ast@plumgrid.com>
 <55F8DD89.5090709@gmail.com> <55F8EBFB.2080009@plumgrid.com>
 <55F8F513.10803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36421 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbIPFIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 01:08:25 -0400
Received: by padhk3 with SMTP id hk3so197623202pad.3
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 22:08:25 -0700 (PDT)
In-Reply-To: <55F8F513.10803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/15 9:50 PM, John Fastabend wrote:
> Looks like you can remove the check. I would prefer to let the stack
> handle this case using normal mechanisms.
>
> I had to do a bit of tracking but netif_running check equates roughly
> to your IFF_UP case via,
...
> Seem reasonable? Or did you put it there to work around some specific
> case I'm missing?

well, in the forwarding path is_skb_forwardable() does the IFF_UP check
before netif_running() has to do it, so yeah this check can be dropped.

Will fix in v2.
Thanks for the review!
