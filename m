From: Dexuan Cui <decui@microsoft.com>
Subject: RE: linux-next network throughput performance regression
Date: Mon, 9 Nov 2015 03:31:15 +0000
Message-ID: <948e8dc00b4a4b6894111a17eaf89b03@HKXPR30MB0039.064d.mgd.msft.net>
References: <6c0fed5fc63a4c3488f5f08409f508ee@HKXPR30MB0039.064d.mgd.msft.net>
 <20151108.215247.1161049251544860672.davem@davemloft.net>
 <eaea78c44de44abcb7936ab070f1b09d@HKXPR30MB0039.064d.mgd.msft.net>
 <20151108.222343.882542189870767346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20151108.222343.882542189870767346.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, November 9, 2015 11:24
> ...
> > Thanks, David!
> > I understand 1 TX queue is the bottleneck (however in Simon's
> > test, TX=1 => 36.7Gb/s, TX=8 => 37.7 Gb/s, so it looks the TX=1 bottleneck
> > is not so obvious).
> > I'm just wondering how the bottleneck became much narrower with
> > recent linux-next in Simon's result (36.7 Gb/s vs. 18.2 Gb/s). IMO there
> > must be some latency somewhere.
> 
> I think the whole thing here is that you misinterpreted what Eric said.
> 
> He is not arguing that some regression did, or did not, happen.
> 
> He instead was making the basic statement about the fact that due to
> the lack of paralellness a single stream TCP case is harder to
> optimize for high speed NICs.
> 
> That is all.
Thanks, I got it. 
I'm actually new to network performance tuning, trying to understand
all the related details. :-)

Thanks,
-- Dexuan
