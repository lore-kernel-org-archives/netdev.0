From: Peter Bieringer <pb@bieringer.de>
Subject: Re: (usagi-users 03019) Re: sysctl net.ipv6.conf.eth0.use_tempaddr
 only recogniced on interface start?
Date: Thu, 10 Feb 2005 21:09:22 +0100
Message-ID: <83D85B170EFC0F1C0451F2EB@worker.muc.bieringer.de>
References: <F5812425CD96109163291692@worker.muc.bieringer.de>
 <20040830.180805.06423987.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, initscripts-ipv6@deepspace6.net
To: usagi-users@linux-ipv6.org
In-Reply-To: <20040830.180805.06423987.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

--On Monday, August 30, 2004 06:08:05 PM +0900 "YOSHIFUJI Hideaki /
=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" <yoshfuji@linux-ipv6.org> wrote:

> In article <F5812425CD96109163291692@worker.muc.bieringer.de> (at Mon, 30
> Aug 2004 10:09:46 +0200), Peter Bieringer <pb@bieringer.de> says:
> 
>> during playing around with RFC3041 capability in Linux kernel, I
>> recognized that the toggle (e.g. net.ipv6.conf.eth0.use_tempaddr) in
>> sysctl is only recognized if interface state changes from down to up,
>> which means you can't enable RFC3041 on an already running interface.
> 
> Not quite true. net.ipv6.conf.eth0.use_tempaddr is recognized, but 
> new temporary addresses is created only when new public address is created
> (by specification).
> 
>> Is this 
>> 
>> a) by design
>> b) temporary issue, will be solved later
>> c) bug, will be solved soon
> 
> a
> 
> and even b; we can probably extend our implementation 
> to create temprary address when net.ipv6.conf.eth0.use_tempaddr is
> changed  from 0 to 1.

Any news on that? Have you plans to implement it?

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
