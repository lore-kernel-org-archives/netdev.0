From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV4 IPComp : threshold comparison
Date: Sun, 18 May 2003 11:07:10 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0305181053450.20294-100000@excalibur.intercode.com.au>
References: <87smrda4q6.wl@karaba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitsuru KANDA / =?ISO-2022-JP?B?GyRCP0BFRBsoQiAbJEI9PBsoQg==?= <mk@linux-ipv6.org>
In-Reply-To: <87smrda4q6.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 18 May 2003, Mitsuru KANDA / [ISO-2022-JP] 神田 充 wrote:

> I'm not sure how exactly we should check threshold.

We should check the length of the IP payload, which the current code is 
only currently doing for tunnel mode.

> In IPsec tunnel mode, the original comparison code 
> seems to be including IP header length.

It is counting the inner IP header, which is correct, as it is part of the 
final IP payload.  The transport mode calculation is incorrect.

> Could you check it?

Your patch fixes the calculation for transport mode, and looks correct.


- James
-- 
James Morris
<jmorris@intercode.com.au>
