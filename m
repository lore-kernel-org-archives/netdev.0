From: Brad House <brad@mcve.com>
Subject: Re: [patches] 2.6.0-test9 - r8169 DMA API conversion
Date: Wed, 19 Nov 2003 19:59:30 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBC11F2.5080805@mcve.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com> <20031118135848.A2451@electric-eye.fr.zoreil.com> <3FBBA76B.4070606@pobox.com> <20031120010056.A19444@electric-eye.fr.zoreil.com> <3FBC05FB.2020409@mcve.com> <20031120014550.A22377@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Brad House <brad_mssw@gentoo.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031120014550.A22377@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

any reason why it's not against the v1.6 ?
the current driver is missing support for the
8110S chip (or at least it doesn't seem to work at all),
so you're cutting out all the chips on the mobos out there.
Haven't looked to see if it's just a PCI ID or other functionality,
but since the V1.2 is from realtek that's in the official
kernel, it would make sense to use the 1.6 patch....

I suppose I could do it, but it would take me much
more time simply because I'm not familiar with the
changes you're making.

-Brad

Francois Romieu wrote:
> Brad House <brad@mcve.com> :
> 
>>Just because I'm way to lazy to actually look, is this
>>against the original r8169, or my patch from the v1.6
>>driver ??
> 
> 
> It is against the original r8169. Once finished, it should look like:
> - first cut at dma api conversion (today)
> - remaining bits of dma api conversion (tomorrow)
> - rx_copybreak (tomorrow)
> - your changes (week-end)
> - big-endian fixes (week-end)
> 
> Each part divided in reasonably small patches to ease the test/review process.
> 
> --
> Ueimor
> 
