From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 1/2] Fix documentation build failure
Date: Mon, 14 Feb 2005 14:36:36 -0800
Message-ID: <20050214143636.3c073df6.davem@davemloft.net>
References: <20050214200017.GA29201@sirius.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Sergey Vlasov <vsu@altlinux.ru>
In-Reply-To: <20050214200017.GA29201@sirius.home>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Feb 2005 23:00:17 +0300
Sergey Vlasov <vsu@altlinux.ru> wrote:

> In linux-2.6.11-rc4-bk2 building of the documentation (make htmldocs)
> fails on "DOCPROC Documentation/DocBook/kernel-api.sgml" because of
> these errors:
> 
> Error(/home/vsu/src/linux-2.6.11-rc4-bk2/include/linux/skbuff.h:936): cannot understand prototype: '#ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB '
> Error(/home/vsu/src/linux-2.6.11-rc4-bk2/drivers/video/fbmem.c:1265): cannot understand prototype: 'const char *global_mode_option; '

I think the htmldoc parser should be fixed instead.
