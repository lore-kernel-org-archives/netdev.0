From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v3 0/2] libbpf: support more map options
Date: Thu, 5 Oct 2017 09:17:06 -0700
Message-ID: <9ca8068a-3e5d-b3f2-7b26-bcce02665311@fb.com>
References: <20171005144158.14860-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chonggang Li <chonggangli@google.com>, <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49108 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751339AbdJEQRy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:17:54 -0400
In-Reply-To: <20171005144158.14860-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/5/17 7:41 AM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
>
> The functional change to this series is the ability to use flags when
> creating maps from object files loaded by libbpf.  In order to do this,
> the first patch updates the library to handle map definitions that
> differ in size from libbpf's struct bpf_map_def.
>
> For object files with a larger map definition, libbpf will continue to load
> if the unknown fields are all zero, otherwise the map is rejected.  If the
> map definition in the object file is smaller than expected, libbpf will use
> zero as a default value in the missing fields.
>
> Craig Gallek (2):
>   libbpf: parse maps sections of varying size
>   libbpf: use map_flags when creating maps
>
>  tools/lib/bpf/libbpf.c | 72 +++++++++++++++++++++++++++++---------------------
>  tools/lib/bpf/libbpf.h |  1 +
>  2 files changed, 43 insertions(+), 30 deletions(-)

lgtm
Acked-by: Alexei Starovoitov <ast@kernel.org>
