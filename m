From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net PATCH 3/3] bpf: devmap, use cond_resched instead of
 cpu_relax
Date: Fri, 8 Sep 2017 15:40:47 -0700
Message-ID: <893ece6d-ac19-fd3e-aee2-f5032d2d13d8@fb.com>
References: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
 <150490447017.11590.17727368565733920857.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <daniel@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43136 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752952AbdIHWlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 18:41:14 -0400
In-Reply-To: <150490447017.11590.17727368565733920857.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/8/17 2:01 PM, John Fastabend wrote:
> Be a bit more friendly about waiting for flush bits to complete.
> Replace the cpu_relax() with a cond_resched().
>
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

unlike patch 1 and 2, this one could have waited till net-next opens,
but I don't mind now. lgtm
Acked-by: Alexei Starovoitov <ast@kernel.org>
