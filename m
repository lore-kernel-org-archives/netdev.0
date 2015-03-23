From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: next-20150323 build: 1 failures 23 warnings (next-20150323)
Date: Mon, 23 Mar 2015 23:16:49 +0100
Message-ID: <CACna6rzRO=vtiv_RfC9nDz+nCZdGGvCh4-zx5cm-W2GSRC1U6w@mail.gmail.com>
References: <E1YZyoN-00019n-50@debutante>
	<20150323212524.GU14954@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:33998 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182AbbCWWQt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:16:49 -0400
Received: by iedfl3 with SMTP id fl3so54173537ied.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:16:49 -0700 (PDT)
In-Reply-To: <20150323212524.GU14954@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 March 2015 at 22:25, Mark Brown <broonie@kernel.org> wrote:
> On Mon, Mar 23, 2015 at 09:38:19AM +0000, Build bot for Mark Brown wr=
ote:
>
> In current -next the bgmac driver does not compile in an ARM
> allmodconfig:
>
>>       arm-allmodconfig
>> ../drivers/net/ethernet/broadcom/bgmac.c:20:27: fatal error: bcm47xx=
_nvram.h: No such file or directory
>
> because this include file is only present on MIPS.  This looks at fir=
st
> glance to have happened in the merge commit edb15d83a875a1f4 from the
> MIPS tree though I think that needs a bit more investigation.

Sorry & thanks. Will fix that tomorrow.

--=20
Rafa=C5=82
