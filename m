From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v3,1/2] b43: Remove unused phy_a code
Date: Thu, 16 Jun 2016 18:56:14 +0300
Message-ID: <87y465unz5.fsf@kamboji.qca.qualcomm.com>
References: <1465052053-26740-1-git-send-email-linux@roeck-us.net>
	<20160616152337.63AB261421@smtp.codeaurora.org>
	<20160616174813.595440bb@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev@lists.infradead.org
To: Michael =?utf-8?Q?B=C3=BCsch?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616174813.595440bb@wiggum> ("Michael =?utf-8?Q?B=C3=BCs?=
 =?utf-8?Q?ch=22's?= message of
	"Thu, 16 Jun 2016 17:48:13 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael B=C3=BCsch <m@bues.ch> writes:

> On Thu, 16 Jun 2016 15:23:37 +0000 (UTC)
> Kalle Valo <kvalo@codeaurora.org> wrote:
>
>> Guenter Roeck <linux@roeck-us.net> wrote:
>> > gcc-6 reports the following error with -Werror=3Dunused-const-vari=
able.
>> >=20
>> > drivers/net/wireless/broadcom/b43/phy_a.c:576:40: error:
>> > 	'b43_phyops_a' defined but not used
>> >=20
>> > Per Michael B=C3=BCsch: "All a-phy code is usused", so remove it a=
ll,
>> > and move the remaining Type-G initialization code into phy_g.c.
>> >=20
>> > Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test rob=
ot]
>> > Cc: Michael B=C3=BCsch <m@bues.ch>
>> > Signed-off-by: Guenter Roeck <linux@roeck-us.net> =20
>>=20
>> Thanks, 2 patches applied to wireless-drivers-next.git:
>>=20
>> 9791333a840f b43: Remove unused phy_a code
>> afdfdc481ea9 b43: Completely remove support for phy_a
>
> Did anybody test this on any hardware? I think this should be tested
> on some G-PHY hardware, before it goes to Linus.

Larry tested these:

"These two patches have been tested on a BCM4318."

https://patchwork.kernel.org/patch/9154719/

--=20
Kalle Valo
