From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] fix uninitialized proto_list_lock
Date: Mon, 4 Apr 2005 14:45:30 -0300
Message-ID: <39e6f6c7050404104578221d01@mail.gmail.com>
References: <20050404173010.GA19451@kvack.org>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20050404173010.GA19451@kvack.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Apr 4, 2005 2:30 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> Please apply the following patch which fixes a BUG() on boot when the
> kernel is compiled with spinlock debugging in bk head.  Cheers,
> 
>                 -ben
> 
> ===== net/core/sock.c 1.67 vs edited =====
> --- 1.67/net/core/sock.c        2005-03-26 18:04:35 -05:00
> +++ edited/net/core/sock.c      2005-04-04 12:46:26 -04:00
> @@ -1352,7 +1352,7 @@
> 
>  EXPORT_SYMBOL(sk_common_release);
> 
> -static rwlock_t proto_list_lock;
> +static rwlock_t proto_list_lock = RW_LOCK_UNLOCKED;

This was already fixed by James Bottomley and its in Dave tree waiting for Linus
to do a pull.

Thanks anyway!

- Arnaldo
