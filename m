From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 01:20:12 +0100
Message-ID: <20041207002012.GB30674@quickstop.soohrt.org>
References: <20041206224107.GA8529@soohrt.org> <E1CbSf8-00047p-00@calista.eckenfels.6bone.ka-ip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bernd Eckenfels <ecki-news2004-05@lina.inka.de>
Content-Disposition: inline
In-Reply-To: <E1CbSf8-00047p-00@calista.eckenfels.6bone.ka-ip.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bernd Eckenfels <ecki-news2004-05@lina.inka.de> wrote:
> In article <20041206224107.GA8529@soohrt.org> you wrote:
> > Removing the iptables rules helps reducing the load a little, but the
> > majority of time is still spent somewhere else.
> 
> In handling Interrupts. Are those equally sidtributed on eth0 and eth1?

Yes they are.

Thanks,
 Karsten

           CPU0       CPU1       
  0:  117199776  133677244    IO-APIC-edge  timer
  1:          0          9    IO-APIC-edge  i8042
  8:          0          4    IO-APIC-edge  rtc
  9:          0          0   IO-APIC-level  acpi
169:        139  893669684   IO-APIC-level  eth0
177:  919803109      30665   IO-APIC-level  eth1
209:     414257     413316   IO-APIC-level  libata
NMI:          0          0 
LOC:  250918849  250918819 
ERR:          0
MIS:          0
