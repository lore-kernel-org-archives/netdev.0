From: Sean Neakums <sneakums@zork.net>
Subject: Re: 2.6.9-rc1-mm4: r8169: irq 16: nobody cared!/TX Timeout
Date: Mon, 13 Sep 2004 13:48:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6uoekaxrks.fsf@zork.zork.net>
References: <6upt4s4cro.fsf@zork.zork.net>
	<20040912110614.GA20942@electric-eye.fr.zoreil.com>
	<6u8ybf2w3f.fsf@zork.zork.net>
	<20040912204319.GA27282@electric-eye.fr.zoreil.com>
	<6uisaj19m4.fsf@zork.zork.net>
	<20040912215933.GB27282@electric-eye.fr.zoreil.com>
	<1095075479.14374.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, jgarzik@pobox.com, akpm@osdl.org,
        netdev@oss.sgi.com,
        Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1095075479.14374.47.camel@localhost.localdomain> (Alan Cox's
	message of "Mon, 13 Sep 2004 12:38:01 +0100")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> On Sul, 2004-09-12 at 22:59, Francois Romieu wrote:
>> > Same result on starting X:
>> > 
>> > irq 16: nobody cared!
>> 
>> It slightly sounds like a broken irq routing.
>> 
>> Any taker for the hot potato ?
>
> Try booting the -mm kernel with "irqpoll" as a boot option and see if it
> survives but struggles. At least I think mm4 has the irqpoll hack in. If
> so then you can work back and try and see whether things like acpi=off
> work

Not sure if you caught the earlier context or if this is relevant, but
acpi=noirq does work.
