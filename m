From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 14:14:45 +0100
Message-ID: <20041207131445.GA1622@soohrt.org>
References: <E1CbSf8-00047p-00@calista.eckenfels.6bone.ka-ip.net> <20041207002012.GB30674@quickstop.soohrt.org> <1102387595.1088.48.camel@jzny.localdomain> <20041207025456.GA525@soohrt.org> <1102389533.1089.51.camel@jzny.localdomain> <20041207032438.GA7767@soohrt.org> <1102390241.1093.59.camel@jzny.localdomain> <20041207040235.GA10501@soohrt.org> <20041207102132.GA28588@quickstop.soohrt.org> <1102422845.1089.105.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Bernd Eckenfels <ecki-news2004-05@lina.inka.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102422845.1089.105.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal wrote:
> > # sar -I 169 5 5
> > 11:20:05         INTR    intr/s
> > 11:20:10          169  10401.40
> 
> That doesnt seem to be too high. 

To recap: 169 is a fibre e1000, eth1 is one of two ports on a dualport
e1000 copper nic. eth1 is still running at about 4k int/s.

14:12:18         INTR    intr/s
14:12:23          169  34012.80
14:12:28          169  33977.60
14:12:33          169  34218.16
14:12:38          169  34060.60
14:12:43          169  34252.60
Average:          169  34104.40

Cheers,
 Karsten
