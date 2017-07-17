From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 09/12] bpf: add bpf_redirect_map helper routine
Date: Mon, 17 Jul 2017 10:16:26 -0700
Message-ID: <596CF0EA.7090100@gmail.com>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810> <20170717162918.24315.8414.stgit@john-Precision-Tower-5810> <cf37d698-66b8-552c-abe4-8704d8fc84ff@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, brouer@redhat.com,
        andy@greyhouse.net
To: Alexei Starovoitov <ast@fb.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34477 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdGQRQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 13:16:37 -0400
Received: by mail-pf0-f178.google.com with SMTP id q85so79467680pfq.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 10:16:37 -0700 (PDT)
In-Reply-To: <cf37d698-66b8-552c-abe4-8704d8fc84ff@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2017 10:00 AM, Alexei Starovoitov wrote:
> On 7/17/17 9:29 AM, John Fastabend wrote:
>> + * int bpf_redirect_map(key, map, flags)
>> + *     redirect to endpoint in map
>> + *     @key: index in map to lookup
>> + *     @map: fd of map to do lookup in
>> + *     @flags: --
> 
> could you please adjust the comment describing return value
> and also fix the comment next to bpf_redirect()
> since that function got reused between tc and xdp.

Looks like Dave pulled it in so I'll roll a patch on top of that
with the comment description fix. Thanks.

> 
> Great stuff!
> looking forward to support in other drivers.
> 
