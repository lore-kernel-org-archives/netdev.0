From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [BUG] bpf is broken in net-next
Date: Sun, 1 Oct 2017 18:34:25 -0700
Message-ID: <20171002013424.tlaictbu7btc4z56@ast-mbp>
References: <20171001140230.6a494b48@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:48807 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdJBBe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 21:34:29 -0400
Received: by mail-pg0-f44.google.com with SMTP id v78so445620pgb.5
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 18:34:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171001140230.6a494b48@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 01, 2017 at 02:02:30PM -0700, Stephen Hemminger wrote:
> Recent regression in net-next building bpf.c in samples/bpf now broken.
> 
> $ make samples/bpf/
> 
> 
>   HOSTCC  samples/bpf/../../tools/lib/bpf/bpf.o
> samples/bpf/../../tools/lib/bpf/bpf.c: In function ‘bpf_create_map_node’:
> samples/bpf/../../tools/lib/bpf/bpf.c:76:13: error: ‘union bpf_attr’ has no member named ‘map_name’; did you mean ‘map_type’?
>   memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
>              ^
> samples/bpf/../../tools/lib/bpf/bpf.c:76:44: error: ‘BPF_OBJ_NAME_LEN’ undeclared (first use in this function)
>   memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));

everything works fine for me...
did you do 'make headers_install' ?
