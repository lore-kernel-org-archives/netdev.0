From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Sun, 29 Jun 2003 18:26:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EFF1349.6020802@hipac.org>
References: <Pine.LNX.4.44.0306290924310.28882-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Pekka

You wrote:
>>We are going to test the stuff tomorrow on an i386 and tell you
>>the results afterwards.

Well, nf-hipac works fine together with the ebtables patch for 2.4.21
on an i386 machine. We expect it to work with other patches too.

>>In principle, nf-hipac should work properly whith the bridge patch.
>>We expect it to work just like iptables apart from the fact that
>>you cannot match on bridge ports.

Well, this statement holds for the native nf-hipac in/out interface
match but of course you can match on bridge ports with nf-hipac
using the iptables physdev match. So everything should be fine :)

> One obvious thing that's missing in your performance and Roberto's figures 
> is what *exactly* are the non-matching rules.  Ie. do they only match IP 
> address, a TCP port, or what? (TCP port matching is about a degree of 
> complexity more expensive with iptables, I recall.)

[answered in private e-mail]


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
