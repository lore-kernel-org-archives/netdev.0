From: Peter Bieringer <pb@bieringer.de>
Subject: Re: (usagi-users 03190) Re: netfilter6: ICMPv6 type 143 doesn't
 match
Date: Tue, 11 Jan 2005 20:56:35 +0100
Message-ID: <60EEE488578EBAD1D9924A43@worker.muc.bieringer.de>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
 <200412270417.iBR4HZRG021429@toshiba.co.jp>
 <20041227.100205.102356251.yoshfuji@linux-ipv6.org>
 <EA4274721EC980393BB13B5E@worker.muc.bieringer.de>
 <20050110131709.GB16911@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, netdev@oss.sgi.com, laforge@gnumonks.org,
        kaber@trash.net, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-users@linux-ipv6.org
In-Reply-To: <20050110131709.GB16911@suse.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Monday, January 10, 2005 02:17:09 PM +0100 Olaf Kirch <okir@suse.de>
wrote:

> On Sat, Jan 08, 2005 at 12:45:14PM +0100, Peter Bieringer wrote:
>> -               ptr = IPV6_HDR_LEN;
>> +               ptr = ((u8*)skb->nh.raw - skb->data) + IPV6_HDR_LEN;
> [...]
>> But it won't help :-((
> 
> The following works for me on 2.6.8:
> 
> 		ptr = ((char *) ipv6 - (char *) skb->data) + IPV6_HDR_LEN;
> 
> Older 2.6 kernels also do not call ipv6_skip_exthdr() in icmp6_match();
> more recent kernels fix this.
> 
> Olaf


I'll be very happy now that I can report that on a recompiled 2.6.10
(latest Fedora Core 3 update), this patch works for me. I will file a RH
bugzilla entry for that and the esp match problem.

Thank you all very much for helping!

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
