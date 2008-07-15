From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Fix netfilter xt_time's time_mt()'s use of do_div()
Date: Tue, 15 Jul 2008 14:10:41 +0200
Message-ID: <487C93C1.4030305@trash.net>
References: <20080711140206.982.19421.stgit@warthog.procyon.org.uk> <487C8D60.9040405@trash.net> <alpine.LNX.1.10.0807151400160.13215@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Howells <dhowells@redhat.com>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757588AbYGOMK5@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0807151400160.13215@fbirervta.pbzchgretzou.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Tuesday 2008-07-15 13:43, Patrick McHardy wrote:
> 
>> David Howells wrote:
>>> Fix netfilter xt_time's time_mt()'s use of do_div() on an s64 by using
>>> div_s64() instead.
>>>
>>> This was introduced by patch ee4411a1b1e0b679c99686629b5eab5a072ce49f.
>> Alternatively we could use an u64 for the time. Jan, any preferences?
> 
> ktime_t and ktime_to_ns operate on signed quantities. I do not think we 
> should be interpreting it as unsigned.

OK, I've applied David's patch. Thanks.
