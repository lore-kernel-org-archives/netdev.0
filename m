From: Peter Bieringer <pb@bieringer.de>
Subject: Re: (usagi-users 03019) Re: sysctl net.ipv6.conf.eth0.use_tempaddr
 only recogniced on interface start?
Date: Mon, 30 Aug 2004 12:19:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4A1C5C18034DEF47D6B4FFD6@worker.muc.bieringer.de>
References: <F5812425CD96109163291692@worker.muc.bieringer.de>
 <20040830.180805.06423987.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
        initscripts-ipv6@deepspace6.net
In-Reply-To: <20040830.180805.06423987.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



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

Ok, should be perhaps noted in ip-sysctl.txt.

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
    (or to 2)

Hmm, from users point of view I would request the extension, because in
case of if sysctl-toggle will be done too late (means RA was already
received), nothing happen until next down->up cycle, if prefix of RA is
still the same.

Would such extension break any specifications?

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
