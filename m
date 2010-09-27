From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: Re: linux-next: build failure after merge of the final tree (net tree related)
Date: Mon, 27 Sep 2010 20:38:50 +0200
Message-ID: <AANLkTi=YHhRWFix1QDuEnRW7r_UaNtp6KSL9uLdUzdqM@mail.gmail.com>
References: <20100927154408.55a28127.sfr@canb.auug.org.au> <AANLkTinHk82jM7Ztwb1aB1xb-hSLeg5Hb07mhYCaeszi@mail.gmail.com>
 <20100927180412.GD11086@tuxdriver.com> <20100927.111818.149846920.davem@davemloft.net>
 <20100927182546.GE11086@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100927182546.GE11086@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 8:25 PM, John W. Linville
<linville@tuxdriver.com> wrote:
>> BTW, if this fuglet going to work if the driver is built modular?
>>
>> The idea of this things seems to be to allow arch platform code to c=
all
>> into it to set things. =A0Such calls from arch platform code are goi=
ng
>> to be "obj-y"
>>
>> So if this is built into the modular driver, I can't see how it
>> can work.
>
> Dave is right -- these Kconfig dependencies (or lack thereof) seem
> to be wrong.

This is why I had to put it in drivers/net/wireless/Makefile (in both
the original patch and in the fix I sent earlier) and not in
drivers/net/wireless/wl12xx/Makefile (as it was in the fix that Dave
was referring to).

This way it works with a modular driver.


> =A0Seems like the OMAP code needs to select the option
> for this code?
>
> John
> --
> John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world wil=
l need a hero, and you
> linville@tuxdriver.com =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be al=
l we have. =A0Be ready.
>
