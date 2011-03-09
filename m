From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Wed, 09 Mar 2011 14:09:28 -0800 (PST)
Message-ID: <20110309.140928.70185544.davem@davemloft.net>
References: <20110301213313.GA6507@albatros>
	<4D6DEE7C.6020700@msgid.tls.msk.ru>
	<20110309220633.GA14750@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjt@tls.msk.ru, linux-kernel@vger.kernel.org, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, therbert@google.com, xiaosuo@gmail.com,
	jesse@nicira.com, kees.cook@canonical.com, eugene@redhat.com,
	dan.j.rosenberg@gmail.com
To: segoon@openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110309220633.GA14750@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segoon@openwall.com>
Date: Thu, 10 Mar 2011 01:06:34 +0300

> On Wed, Mar 02, 2011 at 10:15 +0300, Michael Tokarev wrote:
>> 02.03.2011 00:33, Vasiliy Kulikov wrote:
>> > Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
>> > CAP_NET_ADMIN may load any module from /lib/modules/.  This doesn't mean
>> > that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are
>> > limited to /lib/modules/**.  However, CAP_NET_ADMIN capability shouldn't
>> > allow anybody load any module not related to networking.
>> > 
>> > This patch restricts an ability of autoloading modules to netdev modules
>> > with explicit aliases.  This fixes CVE-2011-1019.
>> []
>> > Reference: https://lkml.org/lkml/2011/2/24/203
>> > 
>> > Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
>> 
>> This looks much saner :)
>> 
>> Signed-off-by: Michael Tokarev <mjt@tls.msk.ru>
> 
> Is there any reason why it is not yet merged?  I've answered to Jake
> Edge that it is not a regression.

I was hoping someone other than me would take this upstream, feel free
to submit it directly to Linus with my ack:

Acked-by: David S. Miller <davem@davemloft.net>
