From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 0/8] sh_eth: deal with #ifdef'fery
Date: Sat, 15 Jun 2013 04:02:48 +0400
Message-ID: <51BBAF28.4040603@cogentembedded.com>
References: <201306060106.51082.sergei.shtylyov@cogentembedded.com> <CANqRtoTM7KUn6Cm9hhQpyVT3qsAFANuD+CufarETSNZwqc5_Sw@mail.gmail.com> <51BBAE97.30009@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <51BBAE97.30009@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/15/2013 04:00 AM, Sergei Shtylyov wrote:

>>>     This series deals mostly with excess #ifdef'fery in the 'sh_eth'
>>> driver.
>>> It doesn't yet get rid of all the #ifdef'fery but that's a matter of
>>> another
>>> patchset. The last patch (it was almost in the middle of the series
>>> before),
>>> contrarywise, adds one missing #ifdef...

>>> [1/8] sh_eth: remove #ifdef around EDSR and GECMR bit definitions
>>> [2/8] sh_eth: use EDSR_ENALL to set EDSR
>>> [3/8] sh_eth: remove duplicate sh_eth_set_duplex() definitions
>>> [4/8] sh_eth: remove SH_ETH_HAS_TSU
>>> [5/8] sh_eth: add IRQ flags to 'struct sh_eth_cpu_data'
>>> [6/8] sh_eth: remove #ifdef around sh_eth_select_mii()
>>> [7/8] sh_eth: consolidate sh_eth_reset()
>>> [8/8] sh_eth: enclose PM code into #ifdef CONFIG_PM

>> Thanks for your work on this. I'm looking forward to a sh-eth driver
>> without #ifdef hell.

>> It may be just me misunderstanding, but the other day I noticed that
>> external PHY handling seems broken in the sh-eth driver. I tried to
>> enable a micron PHY driver but could not make the pieces fit together.

>     What kernel you were using, net-next? It seems that the PHY support
> is indeed broken after this series.

    Oh, I mixed it up. It's broken by the next series, which moved most 
of the SoC specific code out of #ifdef's.

> The phylib simply reports that it didn't find a PHY at the specified address. :-/
>     I'll continue to investigate this on the weekend...

>> Cheers,

>> / magnus

WBR, Sergei


