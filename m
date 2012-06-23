From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: pull request: wireless 2012-06-22
Date: Sat, 23 Jun 2012 16:15:51 +0530
Message-ID: <CAD2nsn1wRUv3+585X0iaTdq4gfaHLk99GifmSktUSHEyrM4Erw@mail.gmail.com>
References: <20120622201716.GB13918@tuxdriver.com>
	<20452.64701.760819.559191@gargle.gargle.HOWL>
	<20453.302.671438.533390@gargle.gargle.HOWL>
	<20120622.165611.2220193371527786713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: c_manoha@qca.qualcomm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120622.165611.2220193371527786713.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 23, 2012 at 5:26 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Sujith Manoharan <c_manoha@qca.qualcomm.com>
> Date: Sat, 23 Jun 2012 05:05:10 +0530
>
>> Sujith Manoharan wrote:
>>> John W. Linville wrote:
>>> > Mohammed Shafi Shajakhan (1):
>>> > =A0 =A0 =A0 ath9k_hw: avoid possible infinite loop in ar9003_get_=
pll_sqsum_dvc
>>>
>>> Um, this commit doesn't really fix anything - the timeout is also
>>> arbitrary. Can you remove this from the 3.5 queue ? Thanks.
>>
>> A review of the patch later, I think it's good. At least there's a
>> WARN_ON_ONCE() to indicate the situation in which the measurement fa=
ils.
>> It might come in handy as a debugging aid.
>
> Thanks for wasting our time.
>
> Make these determinations when changes to into John's tree, not
> later when he asks me to pull them into mine.

apologies for the confusion, i haven't got a better timeout from very
few of the folks
queried, I should have updated that. As the patch is being already
pushed in, if we get
a proper timeout, we would fix it later with a proper timeout.


--=20
thanks,
shafi
