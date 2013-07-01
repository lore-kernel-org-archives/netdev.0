From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 1/2] sh_eth: define/use EESR_RX_CHECK macro
Date: Mon, 1 Jul 2013 21:12:57 +0900
Message-ID: <CANqRtoRQ5OgCuWPC8FW5yBtffNq_E=d=30mE4LB-MxT6GiAwJw@mail.gmail.com>
References: <201306190207.46832.sergei.shtylyov@cogentembedded.com>
	<CANqRtoRNnNuG_r+MW3Yb79jVK_iKm1bRTSvMhw1j4qsWZtphpw@mail.gmail.com>
	<20130619.005005.2262835197239818334.davem@davemloft.net>
	<51C1F826.6040805@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <51C1F826.6040805@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Thu, Jun 20, 2013 at 3:27 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 06/19/2013 11:50 AM, David Miller wrote:
>>> On Wed, Jun 19, 2013 at 7:07 AM, Sergei Shtylyov
>>> <sergei.shtylyov@cogentembedded.com> wrote:
>>>>
>>>> sh_eth_interrupt() uses the same Rx interrupt mask twice to check the
>>>> interrupt
>>>> status register -- #define EESR_RX_CHECK  and use it instead.
>
>
>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
>
>>> Thanks for the patch, nice to see that this driver is moving forward.
>
>
>    Magnus, BTW, are you content with the amount of cleanup that is currently
> queued in the Dave Miller's 'net-next.git' repo, or should I move further:
> e.g., move the SoC specific fields like 'register_type' from the platform
> data to the driver's internal data structure?

I just had a look at this particular driver in net-next.git and I
think it looks very good. Thanks a lot for your efforts!

Regarding moving further with cleanups, it looks to me that it is now
possible to build a single kernel image with this driver included and
use it on multiple SoCs without #ifdef causing trouble. This recent
development has been needed for mach-shmobile to play well with the
multiplatform work going on in the ARM architecture. So since that
seems solved then I'm quite happy with the driver state from a
cleanliness point of view.

As for this driver in general, I'd be very happy to see future
development in these areas:
- DT support
- PHY support for r8a7790 Lager
- PHY IRQ support for r8a7790 Lager

Let me know if I can help you with remote board access.

>>> Can you please include information about which SoC / board this code
>>> has been tested on? As you know, the actual hardware that this driver
>>> is operating on is not very well documented, so at least having
>>> information about the SoC together with the commit message or patch
>>> may help in the future.
>
>
>> Sergei, please make this suggested change and resubmit this series, thank
>> you.
>
>
>    Hm, I guess Magnus didn't really mean patch #1 which doesn't change
> anything in the driver's behavior but only the actual NAPI support. OK, it
> was tested on R8A7778 BOCK-W board and I'll add that to the changelog.

Thanks for updating your code.

In this particular case it may not matter very much, but in general I
believe it is good to include which hardware the code as been tested
on.

Cheers,

/ magnus
