From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sun, 21 Nov 2004 13:24:52 +0000
Message-ID: <41A09724.4050905@phekda.gotadsl.co.uk>
References: <41A09541.5040405@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <41A09541.5040405@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Helo.

Richard Dawe wrote:
> Hello.
> 
> I recently bought an Acer Aspire 1524WLMi, which is a laptop with an AMD 
> Athlon64 3400, a RealTek 8169 GigE chip and a bunch of other stuff.
> 
> I'm currently not able to get more than about 30KB/sec throughput out of 
> the RealTek built-in network adapter. I get a lot of packet loss. The 
> packet loss seems to increase with packet size. Using ping I see that 
> around 1500 bytes packets very little data passes at all.
> 
> I'm running Fedora Core 3. Here are the different kernels I've tried:
[snip]
> Sadly these all had the same terrible performance.
[snip]

Sorry, I forgot to mention the other networking hardware and what I'd 
tried there.

* Draytek Vigor 2600 ADSL modem, which has a built-in 100Mbs switch. I 
can get reasonably close to 100Mbs throughput with this switch. I've had 
no problems with Netgear cards using the "tulip" driver with this switch.

* I tried various bits of cable, including ones that I know work. No 
difference.

* I tried a Netgear 100Mbs hub. No difference.

I would try a cross-over cable to do point-to-point with my desktop PC, 
but I don't have any right now.

I tried to flip the 8169 into half duplex using:

   ethtool -s eth0 duplex half

but that segfaults and leaves the computer at 100% CPU and unresponsive. 
That's with ethtool-2 and ethtool-1.8-4 from FC3. The only choice then 
is to turn the computer off and leave it off for about 10 seconds. If 
you power it up too quickly, then eth0 will not come back up - perhaps 
the 8169 is still wedged?

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
