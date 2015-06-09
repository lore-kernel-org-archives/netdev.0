From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 6/9] net: dsa: mv88e6352: allow egress of unknown
 multicast
Date: Tue, 9 Jun 2015 18:42:01 -0400 (EDT)
Message-ID: <1620255467.632143.1433889721300.JavaMail.zimbra@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-7-git-send-email-vivien.didelot@savoirfairelinux.com> <556DBBC5.5050009@roeck-us.net> <760410371.953763.1433296358640.JavaMail.zimbra@savoirfairelinux.com>
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
Received: from mail.savoirfairelinux.com ([209.172.62.77]:65366 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbbFIWmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 18:42:06 -0400
In-Reply-To: <760410371.953763.1433296358640.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter,

On Jun 2, 2015, at 9:52 PM, Vivien Didelot vivien.didelot@savoirfairelinux.com wrote:
> On Jun 2, 2015, at 10:20 AM, Guenter Roeck linux@roeck-us.net wrote:
>> On 06/01/2015 06:27 PM, Vivien Didelot wrote:
>>> This patch disables egress of unknown unicast destination addresses.
>>>
>> 
>> Hi Vivien,
>> 
>> seems to me this patch is unrelated to the rest of the series.
>> 
>> Not sure if we really want this. If an address is in the arp cache
>> but has timed out from the bridge database, any unicast to that address
>> will no longer be sent. If the bridge database has been flushed for some
>> reason, such as a spanning tree reconfiguration, we'll have a hard time
>> to send anything.
>> 
>> What is the problem you are trying to solve with this patch ?
> 
> TBH, I don't remember which one of the test cases I described in 0/9
> this patch was solving... Some ARP request didn't propagate correctly
> without this, IIRC.
> 
> I'll try to revert the change and do my tests again in order to isolate
> the problem.

Indeed, it seems like this patch is not necessary. I removed it and I
was still able to ping a tagged and untagged port from an untagged one.

I will remove it from this serie.

Thanks,
-v
