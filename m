From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Wed, 23 Oct 2002 10:10:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB6D81F.2050309@candelatech.com>
References: <200210231218.18733.roy@karlsbakk.net> <20021023130101.GA646@outpost.ds9a.nl> <1035379308.5950.3.camel@rth.ninka.net> <200210231542.48673.roy@karlsbakk.net> <20021023170102.GA5302@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roy Sigurd Karlsbakk <roy@karlsbakk.net>,
   "David S. Miller" <davem@rth.ninka.net>, netdev@oss.sgi.com,
   Kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:

> I still refuse to believe that a 1.8GHz Pentium4 can only checksum
> 250megabits/second. MD Raid5 does better and they probably don't use a
> checksum as braindead as that used by TCP.

For what it's worth, I have been able to send and receive 400+ Mbps
of traffic, by directional, on the same machine (ie, about 1600 Mbps
of payload across the PCI bus)

So, it's probably not the e1000 or networking code that is slowing you down.
(This was on a 64/66 PCI, Dual-AMD 2Ghz machine though,
are you running only 32/33 PCI?  If not, where did you find this motherboard!)

Have you tried just reading the information from disk and doing everying except
the final 'send/write/sendto' ?  That would help determine if it is your
file reads that are killing you.

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
