From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next v4 04/16] bpf: Sample bpf program to set
 SYN/SYN-ACK RTOs
Date: Thu, 29 Jun 2017 21:39:14 +0200
Message-ID: <20170629213914.0c0c5c2b@redhat.com>
References: <20170628173124.3299500-1-brakmo@fb.com>
        <20170628173124.3299500-5-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40836 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751592AbdF2TjT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 15:39:19 -0400
In-Reply-To: <20170628173124.3299500-5-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 10:31:12 -0700
Lawrence Brakmo <brakmo@fb.com> wrote:

> +++ b/samples/bpf/tcp_synrto_kern.c
> @@ -0,0 +1,60 @@
> +/* Copyright (c) 2017 Facebook
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of version 2 of the GNU General Public
> + * License as published by the Free Software Foundation.
> + *
> + * BPF program to set SYN and SYN-ACK RTOs to 10ms when using IPv6 addresses
> + * and the first 5.5 bytes of the IPv6 addresses are the same (in this example
> + * that means both hosts are in the same datacenter.

Missing end ")".

I really like this short comment of what the program does, as it helps
people browsing these sample programs. 

Can you also mention in the comment (of all these) bpf programs that
people load this bpf object file via the program 'load_sock_ops'?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
