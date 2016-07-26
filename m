From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH 1/3] net: asix: Add in_pm parameter
Date: Tue, 26 Jul 2016 14:54:32 -0700
Message-ID: <CANEJEGtcEbd8Zw6p_Hwt2JX_D=WRYF4Yf-tQABivNhCqR4btoQ@mail.gmail.com>
References: <1469468424-22685-1-git-send-email-robert.foss@collabora.com>
 <CANEJEGsU97GQ9SzmXGJjdSd_fbTptttHJZb1g_GvNjwEgEzqHg@mail.gmail.com> <f7abc257-54ff-c453-6e7f-34a4103bf7a7@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Grundler <grundler@chromium.org>,
	David Miller <davem@davemloft.net>, Mark_Craske@mentor.com,
	Dean_Jenkins@mentor.com, Vincent Palatin <vpalatin@chromium.org>,
	ivecera@redhat.com, linux@davidrobins.net,
	WK TSAI <wk.tsai@nvidia.com>,
	Chia-Sheng Chang <changchias@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	enric.balletbo@collabora.com,
	Tomeu Vizoso <tomeu.vizoso@collabora.com>
To: Robert Foss <robert.foss@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f7abc257-54ff-c453-6e7f-34a4103bf7a7@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2016 at 2:14 PM, Robert Foss <robert.foss@collabora.com> wrote:
...
> Thanks for the feedback (for this patch and the other ones)!
> I'm preparing a v2 and will submit it withing a day or two.

Excellent! very welcome and thanks again for picking this up.

...
>> FTR, current  drivers/net/usb/ax88179_178a.c uses "in_pm" as well.
>
> Ah! Would you like that to be noted in the commit message?

No - I generally do not muck with commit messages that I didn't write.
It's part of the "finger print" of a patch (so one can trace origin
across distro's and kernel versions).

My comment was intended for reviewers and could be included in the
"comments after the commit message". (ie below the "---" marker in the
patch email).

...
>> BTW, I have two additional changes for AX88772x support sitting in my
>> "needs more work" queue (for quite a while already):
>>    https://chromium-review.googlesource.com/#/c/229620/
>>    "asix: autoneg will set WRITE_MEDIUM reg"
>>
>>    https://chromium-review.googlesource.com/#/c/231162/
>>    "net: asix: see 802.3 spec for phy reset"
>>
>> I would certainly approve if _anyone_ picked these up, tested them,
>> and then submitted them to netdev.
>
> Unfortunately I am without appropriate hardware at the moment.

That's a risky thing to point out for two reasons:

1) I can send you more HW than you could possibly ever use. :)

2) Reviewers of this patch series are already wondering how you
verified the AX88772x patches work on current kernel.org (or
netdev-next) branches.

Please email me with your shipping address (OFFLIST!) and I'll try to
send you some Asix HW to test with.  I'm located in "Silicon Valley"
(USA) and can easily ship in the US. Other countries is a bit harder
and in some cases not possible.

cheers,
grant
