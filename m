From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 6/9] net: dsa: mv88e6352: allow egress of unknown
 multicast
Date: Tue, 2 Jun 2015 21:52:38 -0400 (EDT)
Message-ID: <760410371.953763.1433296358640.JavaMail.zimbra@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-7-git-send-email-vivien.didelot@savoirfairelinux.com> <556DBBC5.5050009@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:54405 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbbFCBwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 21:52:41 -0400
In-Reply-To: <556DBBC5.5050009@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter,

On Jun 2, 2015, at 10:20 AM, Guenter Roeck linux@roeck-us.net wrote:
> On 06/01/2015 06:27 PM, Vivien Didelot wrote:
>> This patch disables egress of unknown unicast destination addresses.
>>
> 
> Hi Vivien,
> 
> seems to me this patch is unrelated to the rest of the series.
> 
> Not sure if we really want this. If an address is in the arp cache
> but has timed out from the bridge database, any unicast to that address
> will no longer be sent. If the bridge database has been flushed for some
> reason, such as a spanning tree reconfiguration, we'll have a hard time
> to send anything.
> 
> What is the problem you are trying to solve with this patch ?

TBH, I don't remember which one of the test cases I described in 0/9
this patch was solving... Some ARP request didn't propagate correctly
without this, IIRC.

I'll try to revert the change and do my tests again in order to isolate
the problem.

Thanks,
-v
