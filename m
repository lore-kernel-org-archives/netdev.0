From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: define/use EESR_RX_CHECK macro
Date: Mon, 01 Jul 2013 16:58:53 +0400
Message-ID: <51D17D0D.7040701@cogentembedded.com>
References: <201306190207.46832.sergei.shtylyov@cogentembedded.com> <CANqRtoRNnNuG_r+MW3Yb79jVK_iKm1bRTSvMhw1j4qsWZtphpw@mail.gmail.com> <20130619.005005.2262835197239818334.davem@davemloft.net> <51C1F826.6040805@cogentembedded.com> <CANqRtoRQ5OgCuWPC8FW5yBtffNq_E=d=30mE4LB-MxT6GiAwJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CANqRtoRQ5OgCuWPC8FW5yBtffNq_E=d=30mE4LB-MxT6GiAwJw@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01-07-2013 16:12, Magnus Damm wrote:

>>>>> sh_eth_interrupt() uses the same Rx interrupt mask twice to check the
>>>>> interrupt
>>>>> status register -- #define EESR_RX_CHECK  and use it instead.

>>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>>>> Thanks for the patch, nice to see that this driver is moving forward.

>>     Magnus, BTW, are you content with the amount of cleanup that is currently
>> queued in the Dave Miller's 'net-next.git' repo, or should I move further:
>> e.g., move the SoC specific fields like 'register_type' from the platform
>> data to the driver's internal data structure?

> I just had a look at this particular driver in net-next.git and I
> think it looks very good. Thanks a lot for your efforts!

> Regarding moving further with cleanups, it looks to me that it is now
> possible to build a single kernel image with this driver included and
> use it on multiple SoCs without #ifdef causing trouble. This recent
> development has been needed for mach-shmobile to play well with the
> multiplatform work going on in the ARM architecture. So since that
> seems solved then I'm quite happy with the driver state from a
> cleanliness point of view.

> As for this driver in general, I'd be very happy to see future
> development in these areas:
> - DT support

    Full DT support won't be possible due to the driver using procedural 
platform data. Partial support will be possible using OF_DEV_AUXDATA() 
to assign the platform data to a device.

> - PHY support for r8a7790 Lager

    Simon seems to be working on this. AFAIK, we don't yet have R8A7790 
based board in our inventory (neither the board manual).

 > - PHY IRQ support for r8a7790 Lager

> Let me know if I can help you with remote board access.

    Yes, you can.

> Cheers,

> / magnus

WBR, Sergei

