From: jamal <hadi@cyberus.ca>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: 06 Dec 2004 21:46:35 -0500
Message-ID: <1102387595.1088.48.camel@jzny.localdomain>
References: <20041206224107.GA8529@soohrt.org>
	 <E1CbSf8-00047p-00@calista.eckenfels.6bone.ka-ip.net>
	 <20041207002012.GB30674@quickstop.soohrt.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bernd Eckenfels <ecki-news2004-05@lina.inka.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261739AbULGCqp@vger.kernel.org>
To: Karsten Desler <kdesler@soohrt.org>
In-Reply-To: <20041207002012.GB30674@quickstop.soohrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Your numbers are very suspect. You may be having other issues in the
box. You should be able to do much higher packet rates even with
iptables compiled in.
Some numbers at:

http://www.suug.ch/sucon/04/slides/pkt_cls.pdf

If all you need is std filtering then consider using tc actions.
I do have a suspicion that your problem has to do with your machine
more than it does with Linux.

cheers,
jamal

On Mon, 2004-12-06 at 19:20, Karsten Desler wrote:
> Bernd Eckenfels <ecki-news2004-05@lina.inka.de> wrote:
> > In article <20041206224107.GA8529@soohrt.org> you wrote:
> > > Removing the iptables rules helps reducing the load a little, but the
> > > majority of time is still spent somewhere else.
> > 
> > In handling Interrupts. Are those equally sidtributed on eth0 and eth1?
> 
> Yes they are.
> 
> Thanks,
>  Karsten
> 
>            CPU0       CPU1       
>   0:  117199776  133677244    IO-APIC-edge  timer
>   1:          0          9    IO-APIC-edge  i8042
>   8:          0          4    IO-APIC-edge  rtc
>   9:          0          0   IO-APIC-level  acpi
> 169:        139  893669684   IO-APIC-level  eth0
> 177:  919803109      30665   IO-APIC-level  eth1
> 209:     414257     413316   IO-APIC-level  libata
> NMI:          0          0 
> LOC:  250918849  250918819 
> ERR:          0
> MIS:          0
> 
> 
