From: Patrick McHardy <kaber@trash.net>
Subject: Re: Is this normal?
Date: Tue, 27 Jan 2009 15:15:19 +0100
Message-ID: <497F16F7.6020504@trash.net>
References: <497F14B1.7070306@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040905030902080506080108"
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497F14B1.7070306@itcare.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040905030902080506080108
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Paweł Staszewski wrote:
> I have Linux that works as Router + traffic management with connection 
> tracking enabled but without making NAT
> 
> About 600Mbit/s TX and 600Mbit/s RX forwarded traffic
> 
> iptables -L -n -v -t raw
> Chain PREROUTING (policy ACCEPT 3340M packets, 2623G bytes)
> pkts bytes target     prot opt in     out     source               
> destination
> 3339M 2621G NOTRACK    all  --  *      *       0.0.0.0/0            
> 0.0.0.0/0
> 
> 
> kernel 2.6.28.2
> CPU: Core 2, speed 2999.98 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a 
> unit mask of 0x00 (Unhalted core cycles) count 100000
> samples  %        image name               app name                 
> symbol name
> 14544205 15.8604  vmlinux                  vmlinux                  
> ctnetlink_del_expect

This doesn't seem to be accurate, I'm guessing its really
ctnetlink_conntrack_event().

Does this patch make any difference?

--------------040905030902080506080108
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfY29yZS5o
IGIvaW5jbHVkZS9uZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19jb3JlLmgKaW5kZXggZTc4
YWZlNy4uYzI1MDY4ZSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvbmV0ZmlsdGVyL25mX2Nv
bm50cmFja19jb3JlLmgKKysrIGIvaW5jbHVkZS9uZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFj
a19jb3JlLmgKQEAgLTU5LDcgKzU5LDcgQEAgc3RhdGljIGlubGluZSBpbnQgbmZfY29ubnRy
YWNrX2NvbmZpcm0oc3RydWN0IHNrX2J1ZmYgKnNrYikKIAlzdHJ1Y3QgbmZfY29ubiAqY3Qg
PSAoc3RydWN0IG5mX2Nvbm4gKilza2ItPm5mY3Q7CiAJaW50IHJldCA9IE5GX0FDQ0VQVDsK
IAotCWlmIChjdCkgeworCWlmIChjdCAmJiBjdCAhPSAmbmZfY29ubnRyYWNrX3VudHJhY2tl
ZCkgewogCQlpZiAoIW5mX2N0X2lzX2NvbmZpcm1lZChjdCkgJiYgIW5mX2N0X2lzX2R5aW5n
KGN0KSkKIAkJCXJldCA9IF9fbmZfY29ubnRyYWNrX2NvbmZpcm0oc2tiKTsKIAkJbmZfY3Rf
ZGVsaXZlcl9jYWNoZWRfZXZlbnRzKGN0KTsK
--------------040905030902080506080108--
