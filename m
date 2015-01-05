From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH next] net: netfilter: nfnetlink_cthelper: Remove 'const'
 and '&' to avoid warnings
Date: Mon, 5 Jan 2015 12:44:32 +0100
Message-ID: <20150105114432.GA17895@salvia>
References: <549AD616.7070709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <549AD616.7070709@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 24, 2014 at 11:04:54PM +0800, Chen Gang wrote:
> The related code can be simplified, and also can avoid related warnin=
gs
> (with allmodconfig under parisc):
>=20
>     CC [M]  net/netfilter/nfnetlink_cthelper.o
>   net/netfilter/nfnetlink_cthelper.c: In function =E2=80=98nfnl_cthel=
per_from_nlattr=E2=80=99:
>   net/netfilter/nfnetlink_cthelper.c:97:9: warning: passing argument =
1 o =E2=80=98memcpy=E2=80=99 discards =E2=80=98const=E2=80=99 qualifier=
 from pointer target type [-Wdiscarded-array-qualifiers]
>     memcpy(&help->data, nla_data(attr), help->helper->data_len);
>            ^
>   In file included from include/linux/string.h:17:0,
>                    from include/uapi/linux/uuid.h:25,
>                    from include/linux/uuid.h:23,
>                    from include/linux/mod_devicetable.h:12,
>                    from ./arch/parisc/include/asm/hardware.h:4,
>                    from ./arch/parisc/include/asm/processor.h:15,
>                    from ./arch/parisc/include/asm/spinlock.h:6,
>                    from ./arch/parisc/include/asm/atomic.h:21,
>                    from include/linux/atomic.h:4,
>                    from ./arch/parisc/include/asm/bitops.h:12,
>                    from include/linux/bitops.h:36,
>                    from include/linux/kernel.h:10,
>                    from include/linux/list.h:8,
>                    from include/linux/module.h:9,
>                    from net/netfilter/nfnetlink_cthelper.c:11:
>   ./arch/parisc/include/asm/string.h:8:8: note: expected =E2=80=98voi=
d *=E2=80=99 but argument is of type =E2=80=98const char (*)[]=E2=80=99
>    void * memcpy(void * dest,const void *src,size_t count);
>           ^

Applied, thanks.
