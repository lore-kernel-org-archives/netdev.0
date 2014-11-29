From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] drivers:net:wireless: Add mutex locking for function,
 b43_op_beacon_set_time in main.c
Date: Sat, 29 Nov 2014 10:04:02 +0100
Message-ID: <CACna6ryjZ-LY06wAMzoL77Wca3McUUT+VYsO4EPO87NqjBnaNw@mail.gmail.com>
References: <1417213013-19758-1-git-send-email-xerofoify@gmail.com>
	<CACna6rxmOC0h9hOpa=5iWFM1THQ8Q4hCi8MnmqkZJbB_U0PJ0A@mail.gmail.com>
	<20141129002148.1beb21d9@wiggum>
	<54793E4E.7050602@gmail.com>
	<20141129095632.69361457@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nick <xerofoify@gmail.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	b43-dev <b43-dev@lists.infradead.org>
To: =?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141129095632.69361457@wiggum>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29 November 2014 at 09:56, Michael B=C3=BCsch <m@bues.ch> wrote:
> On Fri, 28 Nov 2014 22:32:30 -0500
> nick <xerofoify@gmail.com> wrote:
>
>> I don't have hardware for this driver on me, so I didn't test it. Ho=
wever this seems to
>> be correct from my reading of the code around this function and othe=
r locking related
>> to this driver.
>
> From the current docs:
>
>>  * @set_tim: Set TIM bit. mac80211 calls this function when a TIM bi=
t
>>  *      must be set or cleared for a given STA. Must be atomic.
>
> So it is not allowed to lock a mutex here.

Nicholas please be more careful with your patches. It seems your patch
is wrong, you didn't check the docs and you didn't even say in the
first place that it wasn't tested. You could at least submit with with
RFT tag or sth.

--=20
Rafa=C5=82
