From: Brad House <brad@mcve.com>
Subject: Re: [patches] 2.6.0-test9 - r8169 DMA API conversion
Date: Wed, 19 Nov 2003 20:35:46 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBC1A72.9020101@mcve.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com>	 <3FB9A277.70309@pobox.com>	 <20031118135848.A2451@electric-eye.fr.zoreil.com>	 <3FBBA76B.4070606@pobox.com>	 <20031120010056.A19444@electric-eye.fr.zoreil.com>	 <3FBC05FB.2020409@mcve.com>	 <20031120014550.A22377@electric-eye.fr.zoreil.com>	 <3FBC11F2.5080805@mcve.com> <1069292052.3241.36.camel@slurv.pasop.tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Francois Romieu <romieu@fr.zoreil.com>,
        Jeff Garzik <jgarzik@pobox.com>, Brad House <brad_mssw@gentoo.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Tomt <andre@tomt.net>
In-Reply-To: <1069292052.3241.36.camel@slurv.pasop.tomt.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

yes, I definately misunderstood then ...
sorry ;)
I'll just apply the patches to my version and see what happens ;)

-Brad

Andre Tomt wrote:
> On Thu, 2003-11-20 at 01:59, Brad House wrote:
> 
>>any reason why it's not against the v1.6 ?
> 
> 
> I think you misunderstood. If I intepret the list correctly, the 1.6
> changes are in that list (as "your changes (week-end)".)
> 
> 
>>the current driver is missing support for the
>>8110S chip (or at least it doesn't seem to work at all),
>>so you're cutting out all the chips on the mobos out there.
>>Haven't looked to see if it's just a PCI ID or other functionality,
>>but since the V1.2 is from realtek that's in the official
>>kernel, it would make sense to use the 1.6 patch....
> 
> 
> IIRC, the realtek one got cleaned up a great deal before entering
> mainline, both bug-fixes and coding style cleanups. Your patch may
> revert a lot of that work (I havn't looked at it closely.) Also the
> changelog differs for the 1.2 entry between the two versions, indicating
> just this.
> 
> Lets take one step at a time ;-)
> 
> 
>>>It is against the original r8169. Once finished, it should look like:
>>>- first cut at dma api conversion (today)
>>>- remaining bits of dma api conversion (tomorrow)
>>>- rx_copybreak (tomorrow)
>>>- your changes (week-end)
>>>- big-endian fixes (week-end)
>>>
>>>Each part divided in reasonably small patches to ease the test/review process.
> 
> 
