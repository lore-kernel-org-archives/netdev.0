From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 1/2] cls_bpf: introduce integrated actions
Date: Thu, 17 Sep 2015 08:37:34 -0400
Message-ID: <55FAB40E.304@mojatatu.com>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com>
 <1442383543-4720-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:32910 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbIQMhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 08:37:36 -0400
Received: by igbkq10 with SMTP id kq10so11213397igb.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 05:37:36 -0700 (PDT)
In-Reply-To: <1442383543-4720-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/15 02:05, Alexei Starovoitov wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
>
> Often cls_bpf classifier is used with single action drop attached.
> Optimize this use case and let cls_bpf return both classid and action.
> For backwards compatibility reasons enable this feature under
> TCA_BPF_FLAG_ACT_DIRECT flag.
>

This is going off in a different direction really.
You are replicating the infrastructure inside bpf.

cheers,
jamal
