From: bert hubert <ahu@ds9a.nl>
Subject: Re: 2.6 IPSec Throughput puzzle
Date: Wed, 29 Dec 2004 13:12:00 +0100
Message-ID: <20041229121200.GA12199@outpost.ds9a.nl>
References: <EF311E6F9B0B0848A49ED20B06E9CB27031FDE77@gluon.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Shekhar Kshirsagar <shekhark@juniper.net>
Content-Disposition: inline
In-Reply-To: <EF311E6F9B0B0848A49ED20B06E9CB27031FDE77@gluon.jnpr.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 28, 2004 at 07:17:26PM -0800, Shekhar Kshirsagar wrote:

> I'm really puzzled with the performance results I'm getting. The
> performance drop with AH seems high, but worst is performance drop with
> null-esp in transport mode. Another strange observation is that DES
> throughput is greater than null encryption throughput.

Thanks for doing these benchmarks! I did some myself some time ago, but my
hardware isn't representative of anything (consisting of a pentium pro 200
against a P3 1GHz).

> Throughput without IPSec	: 936 MBits/s ( 25% CPU Util)
> Transport mode AH - SHA1      : 398 MBits/s (100% CPU Util)
> Transport mode ESP - null/SHA1:  62 MBits/s (100% CPU Util) 
> Transport mode ESP - des/SHA1 : 111 MBits/s (100% CPU Util)
> Transport mode ESP - 3des/SHA1:  54 MBits/s (100% CPU Util)
> Transport mode ESP - aes/SHA1 : 192 MBits/s (100% CPU Util)
> 
> Do these numbers sound reasonable?
> (I don't have any iptable rules)

It is very easy to use oprofile these days, I suggest you profile for a bit,
should easily tell you what the culprit is. 62MBit/s sounds very low.

Good luck!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
