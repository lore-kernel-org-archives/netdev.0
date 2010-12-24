From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Help: major pppoe regression since 2.6.35 (panic on first ppp
 conection)?
Date: Fri, 24 Dec 2010 16:13:25 +0100
Message-ID: <20101224151325.GA1895@del.dom.local>
References: <20101222110021.GA8985@ff.dom.local>
 <4D122093.6060900@scarlet.be>
 <1293035100.3027.247.camel@edumazet-laptop>
 <4D132C5F.8090404@scarlet.be>
 <1293106348.7789.5.camel@edumazet-laptop>
 <20101223202523.GA1913@del.dom.local>
 <4D148271.8030509@scarlet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Joel Soete <soete.joel@scarlet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D148271.8030509@scarlet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 24, 2010 at 11:22:25AM +0000, Joel Soete wrote:
> Hello Jarek,
Hi Joel,

> Ok I get a clean 2.6.37-rc7 vanilla src and apply your debugging
> patch and grab the attached syslog-2.6.37-rc7-t2.gz with obviously a
> lot of "warning" (but as well as with Eric's patch, kernel survived
> to a lynx connection to ftp.eu.kernel.org to download of a snapshot
> patch ;<) )

Yes, even more than I expected... I hope the list will forgive us ;-)

> I copy my all /etc/ppp dir into a PPP.ANONYM dir in which I replaced letters of my account and passwd by '.'
> To give more details, I am using a debian 'testing' distro with following ppp pkg:
> # dpkg -l ppp\*
> Desired=Unknown/Install/Remove/Purge/Hold
> | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
> |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
> ||/ Name                        Version                     Description
> +++-===========================-===========================-======================================================================
> ii  ppp                         2.4.5-4                     Point-to-Point Protocol (PPP) - daemon
> ii  pppconfig                   2.3.18+nmu2                 A text menu based utility for configuring ppp
> ii  pppoe                       3.8-3                       PPP over Ethernet driver
> ii  pppoeconf                   1.19                        configures PPPoE/ADSL connections
> ii  pppstatus                   0.4.2-10                    console-based PPP status monitor
> 
> and I used pppoeconf to configure my ADSL connection to my ISP using
> all defaults and just the recommended mtu of 1492 (which seems
> effectively to works fine to me) and I don't remember to have change
> anything else excepted my account and passwd.

Should be enough reading to me for the next day or two.

> Thanks for help and have Happy Christmas,
> 	J.

Thanks and Happy Holidays!
Jarek P.
