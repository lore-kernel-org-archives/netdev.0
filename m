From: Peter Bieringer <pb@bieringer.de>
Subject: Re: [PATCH] IPV6: added sysctl for maximum number of addresses
Date: Sun, 18 Jan 2004 22:15:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <59590000.1074460559@worker.muc.bieringer.de>
References: <20040115.213014.133549139.yoshfuji@linux-ipv6.org>
 	<Pine.LNX.4.44.0401151721380.16629-100000@netcore.fi>
 	<20040116.003433.120676843.yoshfuji@linux-ipv6.org>
 <20040115141016.15277a53.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040115141016.15277a53.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Thursday, January 15, 2004 02:10:16 PM -0800 "David S. Miller"
<davem@redhat.com> wrote:

> On Fri, 16 Jan 2004 00:34:33 +0900 (JST)
> YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:
> 
>> My point is the value becomes configurable.
>> "16" is consistent with current behavior.
>> I do not change the default value with this patch.
>> 
>> If you think it is too small, feel free to submit a patch to increase 
>> the default value.
> 
> I agree with Yoshfuji-san, making it configurable and changing the default
> are two different decisions to make and thus two different changes to
> make.
> 
> I will apply Yoshfuji's patch to make it configurable, and someone can
> submit the change to make the default different and we can discuss that.

Hmm, since when this limit exists?

Looks like it was introduced after 2.4.20-28.9 (RHL9 kernel)

One of my newer public servers (running upper shown kernel version) have
already 23 IPv6 addresses:

# ip addr show dev eth0|grep 2001 |wc -l
     23

Mostly used for one IPv6 address per "on-IPv6-no-longer-virtual-IP-less"
Apache2 webserver.

So I have the same opinion like Pekka, 16 would be a little bit to view, 64
would be a good default value for the limit.

Just my 2 cents,
        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
