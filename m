From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/3] samples/bpf: check before defining offsetof
Date: Tue, 25 Apr 2017 14:27:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFDAD25@AcuExch.aculab.com>
References: <20170424133108.31595-1-alexander@alemayhu.com>
 <20170424133108.31595-4-alexander@alemayhu.com>
 <58FE0E96.9020403@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "ast@fb.com" <ast@fb.com>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
        Alexander Alemayhu <alexander@alemayhu.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:53982 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1947878AbdDYO1V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:27:21 -0400
In-Reply-To: <58FE0E96.9020403@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann
> Sent: 24 April 2017 15:41
> To: Alexander Alemayhu; netdev@vger.kernel.org
> Cc: ast@fb.com
> Subject: Re: [PATCH net-next 3/3] samples/bpf: check before defining offsetof
> 
> On 04/24/2017 03:31 PM, Alexander Alemayhu wrote:
> > Fixes the following warning
> >
> > samples/bpf/test_lru_dist.c:28:0: warning: "offsetof" redefined
> >   #define offsetof(TYPE, MEMBER) ((size_t)&((TYPE *)0)->MEMBER)
> >
> > In file included from ./tools/lib/bpf/bpf.h:25:0,
> >                   from samples/bpf/libbpf.h:5,
> >                   from samples/bpf/test_lru_dist.c:24:
> > /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include/stddef.h:417:0: note: this is the location of the
> previous definition
> >   #define offsetof(TYPE, MEMBER) __builtin_offsetof (TYPE, MEMBER)
> >
> > Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Isn't the correct fix to include stddef.h ?

	David
