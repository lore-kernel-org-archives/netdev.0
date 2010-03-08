From: Joe Perches <joe@perches.com>
Subject: Re: drivers/net/mac8390.c: Remove useless memcpy casting
Date: Mon, 08 Mar 2010 08:16:00 -0800
Message-ID: <1268064960.1925.19.camel@Joe-Laptop.home>
References: <201003022001.o22K16vJ011337@hera.kernel.org>
	 <10f740e81003070119s3eb433d9r4f1cc79e59d56316@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10f740e81003070119s3eb433d9r4f1cc79e59d56316@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2010-03-07 at 10:19 +0100, Geert Uytterhoeven wrote:
> ... hence you introduced 3 compiler warnings:
> 
> drivers/net/mac8390.c:249: warning: passing argument 1 of
> '__builtin_memcpy' makes pointer from integer without a cast
> drivers/net/mac8390.c:254: warning: passing argument 1 of
> 'word_memcpy_tocard' makes pointer from integer without a cast
> drivers/net/mac8390.c:256: warning: passing argument 2 of
> 'word_memcpy_fromcard' makes pointer from integer without a cast

Thanks, I'll submit a patch to fix it by tomorrow or so.
