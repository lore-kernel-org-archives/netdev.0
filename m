From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: 2.6.9-rc1-mm4: r8169: irq 16: nobody cared!/TX Timeout
Date: Mon, 13 Sep 2004 12:38:01 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1095075479.14374.47.camel@localhost.localdomain>
References: <6upt4s4cro.fsf@zork.zork.net>
	 <20040912110614.GA20942@electric-eye.fr.zoreil.com>
	 <6u8ybf2w3f.fsf@zork.zork.net>
	 <20040912204319.GA27282@electric-eye.fr.zoreil.com>
	 <6uisaj19m4.fsf@zork.zork.net>
	 <20040912215933.GB27282@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sean Neakums <sneakums@zork.net>, jgarzik@pobox.com, akpm@osdl.org,
	netdev@oss.sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266616AbUIMMlq@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040912215933.GB27282@electric-eye.fr.zoreil.com>
List-Id: netdev.vger.kernel.org

On Sul, 2004-09-12 at 22:59, Francois Romieu wrote:
> > Same result on starting X:
> > 
> > irq 16: nobody cared!
> 
> It slightly sounds like a broken irq routing.
> 
> Any taker for the hot potato ?

Try booting the -mm kernel with "irqpoll" as a boot option and see if it
survives but struggles. At least I think mm4 has the irqpoll hack in. If
so then you can work back and try and see whether things like acpi=off
work
