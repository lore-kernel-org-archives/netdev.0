From: Jason Wang <jasowang@redhat.com>
Subject: Re: linux-next: build warning after merge of the net-next tree
Date: Mon, 4 Jul 2016 13:19:37 +0800
Message-ID: <5779F1E9.9070505@redhat.com>
References: <20160704131552.22b44d58@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160704131552.22b44d58@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016=E5=B9=B407=E6=9C=8804=E6=97=A5 11:15, Stephen Rothwell wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) produced this warning:
>
> drivers/net/tun.c: In function 'tun_do_read.part.5':
> /home/sfr/next/next/drivers/net/tun.c:1491:6: warning: 'err' may be u=
sed uninitialized in this function [-Wmaybe-uninitialized]
>    int err;
>        ^
>
> Introduced by commit
>
>    1576d9860599 ("tun: switch to use skb array for tx")
>
> I can't easily see if this is a false positive.
>

Thanks for the reporting, will post a fix.
