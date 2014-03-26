From: SeongJae Park <sj38.park@gmail.com>
Subject: Re: [PATCH] ixen-netback: fix trivial printf format build warning
Date: Wed, 26 Mar 2014 19:34:21 +0900
Message-ID: <CAEjAshoYWeCdVD9mC4f6EQkQkd-dVuk47gGEZ-4ig-uVS938ag@mail.gmail.com>
References: <1395806210-23528-1-git-send-email-sj38.park@gmail.com> <1395828547.22808.28.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: trivial@kernel.org, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395828547.22808.28.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for let me know kindly :)

On Wed, Mar 26, 2014 at 7:09 PM, Ian Campbell <Ian.Campbell@citrix.com>=
 wrote:
> On Wed, 2014-03-26 at 12:56 +0900, SeongJae Park wrote:
>> Fix following trivial build warning:
>>
>> drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_de=
alloc_action=E2=80=99:
>> drivers/net/xen-netback/netback.c:1585:8: warning:
>> format =E2=80=98%x=E2=80=99 expects argument of type
>>  =E2=80=98unsigned int=E2=80=99, but argument 3 has type =E2=80=98lo=
ng int=E2=80=99 [-Wformat=3D]
>>         gop - vif->tx_unmap_ops, ret);
>>         ^
>>
>> Signed-off-by: SeongJae Park <sj38.park@gmail.com>
>
> Thanks but davem indicated overnight that he has already pushed a
> suitable fix to net-next.
>
> Ian.
>
>
