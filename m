From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() loop upper
 bound
Date: Wed, 12 Aug 2015 09:21:35 -0700
Message-ID: <55CB728F.3070502@plumgrid.com>
References: <1439391432-4690-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiakaixu@huawei.com
To: Wei-Chun Chao <weichunc@plumgrid.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35932 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbbHLQVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 12:21:39 -0400
Received: by pdco4 with SMTP id o4so9006889pdc.3
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 09:21:38 -0700 (PDT)
In-Reply-To: <1439391432-4690-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/12/15 7:57 AM, Wei-Chun Chao wrote:
> Verifier rejects programs incorrectly.
>
> Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read()")
> Cc: Kaixu Xia <xiakaixu@huawei.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>

thanks a lot for tracking it down!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
