From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] xfrm ip6ip6
Date: Sun, 1 Jun 2003 02:06:07 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306010204260.7298-100000@excalibur.intercode.com.au>
References: <87fzmv5ejc.wl@karaba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitsuru KANDA / =?ISO-2022-JP?B?GyRCP0BFRBsoQiAbJEI9PBsoQg==?= <mk@linux-ipv6.org>
In-Reply-To: <87fzmv5ejc.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 1 Jun 2003, Mitsuru KANDA / [ISO-2022-JP] 神田 充 wrote:

> I honestly have to say it is not tested well.

Btw, one simple way to test the xfrm tunneling is to set up a plain ipcomp 
tunnel and run ssh or https over it, which should cause non-compressed 
packets to be sent (they will fail the compressability test).


- James
-- 
James Morris
<jmorris@intercode.com.au>
