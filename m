From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: Some sleeping function called from invalid context
Date: Tue, 5 Apr 2005 08:13:51 -0300
Message-ID: <39e6f6c70504050413666ea29d@mail.gmail.com>
References: <1112693744.7960.2.camel@pegasus>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1112693744.7960.2.camel@pegasus>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Apr 5, 2005 6:35 AM, Marcel Holtmann <marcel@holtmann.org> wrote:
> Hi,
> 
> while testing the latest kernel from the Bitkeeper repository, I got
> some sleeping functions called from invalid context:
> 
> Freeing unused kernel memory: 180k freed
> Debug: sleeping function called from invalid context at mm/slab.c:2090
> in_atomic():1, irqs_disabled():0
>  [<c0119936>] __might_sleep+0xa6/0xb0
>  [<c014ab93>] kmem_cache_alloc+0x73/0x80
>  [<c0149c0e>] kmem_cache_create+0xfe/0x630
>  [<c026994d>] proto_register+0x9d/0xc0
>  [<f88c901c>] af_unix_init+0x1c/0x7a [unix]
>  [<c0139d62>] sys_init_module+0x1b2/0x290
>  [<c0103025>] syscall_call+0x7/0xb
> NET: Registered protocol family 1

Damn, thanks for reporting, looking at it now.

- Arnaldo
