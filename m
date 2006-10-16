From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Hardware bug or kernel bug?
Date: Mon, 16 Oct 2006 12:25:00 +0200
Message-ID: <20061016102500.GA1709@ff.dom.local>
References: <20061013085605.GA1690@ff.dom.local> <200610131256.54546.dj@david-web.co.uk> <20061013130648.GC1690@ff.dom.local> <200610131724.40631.dj@david-web.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.go2.pl ([193.17.41.41]:40654 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1030224AbWJPKUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 06:20:03 -0400
To: David Johnson <dj@david-web.co.uk>
Content-Disposition: inline
In-Reply-To: <200610131724.40631.dj@david-web.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 13, 2006 at 05:24:39PM +0100, David Johnson wrote:
> On Friday 13 October 2006 14:06, Jarek Poplawski wrote:
> >
> > Probably - but only with networking. So I'd try with this debugging
> > like in my first reply plus maybe 2.6.19-rc1 (e1000 - btw. I hope
> > this other tested card was different model - and locking improved)
> > and resend conclusions to netdev@vger.kernel.org.
> >
> 
> OK I built a 2.6.19-rc1 kernel with a minimal config as you describe and I 
> cannot reproduce the reboots with this kernel. My .config:
> http://www.david-web.co.uk/download/config

I've seen more minimal minimal configs but if it works
it is 50% of success. 

> The other NIC I tried was a D-Link DL10050-based card which I think uses the 
> dl2k module.
> 
> I tried to reproduce the problem under Windows (2k), which didn't reboot but 
> did still suffer from it I believe. Randomly during an scp transfer (using 
> the PuTTY scp client) Windows will lock-up for about 30 seconds, making an 
> entry in the event log indicating that there was a time-out talking to the 
> IDE controller, then continuing. Could the same thing be happening in Linux? 
> If Linux can't talk to the IDE controller when trying to write to disk, how 
> does it handle that?

Was this lock-up effect visible during above 2.6.19-rc1 tests?
If not I'd try to continue linux debbuging:
- is 2.6.19-rc1 working with "normal" config (use make oldconfig
to "upgrade" .config),
- is 2.6.17 working with "minimal" config (use make oldconfig),
- changing one or two options at a time try to find which one makes
the effect returns (acpi, smp...). 

Regards,
Jarek P.

PS: Sorry for late reply - I was offline.
