From: David Cohen <david.a.cohen@linux.intel.com>
Subject: Re: [gpio:for-next 67/67] pch_gbe_main.c:undefined reference to `devm_gpio_request_one'
Date: Thu, 31 Oct 2013 12:12:32 -0700
Message-ID: <5272ABA0.7040503@linux.intel.com>
References: <52691c0b.BIIOKlR6F81qU+tE%fengguang.wu@intel.com> <20131025044027.GA27083@localhost> <CACRpkdaJVE44UGRAZ0tnQSArrs+DuVFhVssW6riWmdp8-6E6BQ@mail.gmail.com> <1382696677.4970.40.camel@dvhart-mobl4.amr.corp.intel.com> <CACRpkdYvOMiBOXRi61LjemMSoafR6kv3XoY=A5E90hwMumdw9A@mail.gmail.com> <CACRpkdYDUKK-jAeeHECfRcKM+-MDuyarDMGDP0p39U_-WLgd8w@mail.gmail.com> <526AE0EB.4020602@linux.intel.com> <526AE1E2.9080909@linux.intel.com> <1382819615.23829.16.camel@dvhart-mobl4.amr.corp.intel.com> <1382822142.23829.46.camel@dvhart-mobl4.amr.corp.intel.com> <526CA546.7040406@linux.intel.com> <CACRpkdZM8BBR6NAUTuSpEErZe2541-CvuwFSe13FDfxOBnnygA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
To: Linus Walleij <linus.walleij@linaro.org>,
	Darren Hart <dvhart@linux.intel.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <CACRpkdZM8BBR6NAUTuSpEErZe2541-CvuwFSe13FDfxOBnnygA@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2013 11:21 AM, Linus Walleij wrote:
> On Sat, Oct 26, 2013 at 10:31 PM, David Cohen
> <david.a.cohen@linux.intel.com> wrote:
> 
>> Maybe if GPIOLIB has the static inline stubs returning -ENODEV we could
>> use a patch similar to the one attached here.
> 
> I've added stubs returning -EINVAL just like all siblings there, if you
> like to have this changed, send a patch changing it to -ENODEV
> and this patch on top as 2/2 please.

Thanks.

Darren, do you have any objections WRT failing pch_gbe on Minnowboard
due to lack of GPIO?

BR, David
