From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [PATCH] eliminate large inline's in skbuff
Date: Thu, 6 May 2004 20:13:56 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405062013.32545.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200404212226.28350.vda@port.imtp.ilyichevsk.odessa.ua> <200405020037.47712.vda@port.imtp.ilyichevsk.odessa.ua> <20040505145949.05ea67a7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040505145949.05ea67a7@dell_ss3.pdx.osdl.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 06 May 2004 00:59, Stephen Hemminger wrote:
> > On Wednesday 28 April 2004 00:21, Stephen Hemminger wrote:
> > > This takes the suggestion and makes all the locked skb_ stuff, not
> > > inline. It showed a 3% performance improvement when doing single TCP
> > > stream over 1G Ethernet between SMP machines. Test was average of 10
> > > iterations of iperf for 30 seconds and SUT was 4 way Xeon.  Http
> > > performance difference was not noticeable (less than the std. deviation
> > > of the test runs).
>
> The original tests were suspect for a whole lot of reasons.  Running the
> proper tests shows no performance differences.  The best theory as to why
> there was a difference in earlier tests is that memory debugging was
> enabled;  that caused each buffer to be overwritten with a memset. When
> that happened, the test ends up measuring the speed of the memory and cache
> bandwidth, not the CPU or the network.

"no detectable difference" was the most expecter result indeed.
Thank you for actually testing that.
--
vda
