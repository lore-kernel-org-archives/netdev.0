From: Jan Yenya Kasprzak <kas@fi.muni.cz>
Subject: Re: [PATCH] wan: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 16:42:09 +0100
Message-ID: <20090225154202.GX10622@fi.muni.cz>
References: <49A51BF1.2030503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:48388 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760105AbZBYPmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 10:42:38 -0500
Content-Disposition: inline
In-Reply-To: <49A51BF1.2030503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun wrote:
: Remove some pointless conditionals before kfree_skb().
:=20
: Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Acked-by: Jan "Yenya" Kasprzak <kas@fi.muni.cz>

Thanks,

-Yenya

: ---
:  drivers/net/wan/cosa.c |    3 +--
:  1 files changed, 1 insertions(+), 2 deletions(-)
:=20
: diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
: index 0d7ba11..d276d72 100644
: --- a/drivers/net/wan/cosa.c
: +++ b/drivers/net/wan/cosa.c
: @@ -731,8 +731,7 @@ static char *cosa_net_setup_rx(struct channel_dat=
a *chan, int size)
:  	 * We can safely fall back to non-dma-able memory, because we have
:  	 * the cosa->bouncebuf pre-allocated.
:  	 */
: -	if (chan->rx_skb)
: -		kfree_skb(chan->rx_skb);
: +	kfree_skb(chan->rx_skb);
:  	chan->rx_skb =3D dev_alloc_skb(size);
:  	if (chan->rx_skb =3D=3D NULL) {
:  		printk(KERN_NOTICE "%s: Memory squeeze, dropping packet\n",
: --=20
: 1.5.3.8
:=20
:=20
:=20

--=20
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - privat=
e}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18=
A5E |
| http://www.fi.muni.cz/~kas/    Journal: http://www.fi.muni.cz/~kas/bl=
og/ |
>>  If you find yourself arguing with Alan Cox, you=E2=80=99re _probabl=
y_ wrong.  <<
>>     --James Morris in "How and Why You Should Become a Kernel Hacker=
"  <<
