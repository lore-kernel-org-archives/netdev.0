From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] ewrk3: silence GCC warning
Date: Sun, 25 Nov 2012 11:45:43 +0100
Message-ID: <CAFLxGvyfH3WdNpsGzV2OgvyT_8hu4U03+HEuv3u9DvSkOmNBtA@mail.gmail.com>
References: <1353759165.1420.33.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353759165.1420.33.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 24, 2012 at 1:12 PM, Paul Bolle <pebolle@tiscali.nl> wrote:
> Building ewrk3.o triggers this GCC warning:
>     drivers/net/ethernet/dec/ewrk3.c: In function '__check_irq':
>     drivers/net/ethernet/dec/ewrk3.c:1915:1: warning: return from incompatible pointer type [enabled by default]
>
> This can be trivially fixed by changing the 'irq' parameter from int to
> byte (which is the alias for unsigned char for module parameters).
>
> While we're touching this code also drop an outdated comment, that
> should have been dropped with the patch named "MODULE_PARM conversions"
> from early 2005.

Please send this change as an additional patch.

-- 
Thanks,
//richard
