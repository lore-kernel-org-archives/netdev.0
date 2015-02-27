From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: Re: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation
Date: Fri, 27 Feb 2015 15:42:49 +0800
Message-ID: <54F01FF9.50108@linux.intel.com>
References: <54DC1D7D.5050407@linux.intel.com> <54E0072D.3020802@linux.intel.com> <063D6719AE5E284EB5DD2968C1650D6D1CAE430C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Laight <David.Laight@ACULAB.COM>,
	Kalle Valo <kvalo@codeaurora.org>,
	"brudley@broadcom.com" <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	"meuleman@broadcom.com" <meuleman@broadcom.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"pieterpg@broadcom.com" <pieterpg@broadcom.com>,
	"hdegoede@redhat.com" <hdegoede@redhat.com>,
	"wens@csie.org" <wens@csie.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"brcm80211-dev-list@broadcom.com" <brcm80211-dev-list@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE430C@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2015/2/16 17:50, David Laight wrote:
>>> WiFi chip has 2 SDIO functions, and PM core will trigger
>>> twice suspend/resume operations for one WiFi chip to do
>>> the same things. This patch avoid this case.
> Do you want to suspend on the first or last request?
>
> In general it might be that one function is in use and
> something wants to suspend the other (as inactive).
>
> If they suspend together you might need to pretend the
> first function is suspended but only do the real power-saving
> device suspend when all the functions have been suspended.
I was in Chinese new-year vacation these few days. So sorry for late re=
sponse.

Suspend/Resume entry functions of brcmfmac driver does not differentiat=
e between two functions, performs the same operations instead.


Thanks,
Zhonghui
>
> 	David
>
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD{=EF=BF=BD=
=EF=BF=BD*=DE=95=EF=BF=BD,=EF=BF=BD{ay=EF=BF=BD=1D=CA=87=DA=99=EF=BF=BD=
,j=07=EF=BF=BD=EF=BF=BDf=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=
=BF=BDz=EF=BF=BD=1E=EF=BF=BDw=EF=BF=BD=EF=BF=BD=EF=BF=BD=0C=EF=BF=BD=EF=
=BF=BD=EF=BF=BDj:+v=EF=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BDj=EF=BF=BDm=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=07=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDzZ=
+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j"=EF=BF=BD=EF=BF=BD=
!tml=3D
