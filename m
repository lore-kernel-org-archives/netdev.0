From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net-next PATCH 09/12] bpf: add bpf_redirect_map helper routine
Date: Mon, 17 Jul 2017 10:00:27 -0700
Message-ID: <cf37d698-66b8-552c-abe4-8704d8fc84ff@fb.com>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
 <20170717162918.24315.8414.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <brouer@redhat.com>, <andy@greyhouse.net>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33450 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751315AbdGQRAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 13:00:53 -0400
In-Reply-To: <20170717162918.24315.8414.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/17/17 9:29 AM, John Fastabend wrote:
> + * int bpf_redirect_map(key, map, flags)
> + *     redirect to endpoint in map
> + *     @key: index in map to lookup
> + *     @map: fd of map to do lookup in
> + *     @flags: --

could you please adjust the comment describing return value
and also fix the comment next to bpf_redirect()
since that function got reused between tc and xdp.

Great stuff!
looking forward to support in other drivers.
