From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port
 speeds/duplex
Date: Fri, 19 Jun 2015 11:48:28 -0400 (EDT)
Message-ID: <2017950579.56305.1434728908030.JavaMail.zimbra@savoirfairelinux.com>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch> <1434129537-15252-3-git-send-email-andrew@lunn.ch> <557F0CD5.4070705@gmail.com> <536480200.118000.1434564592107.JavaMail.zimbra@savoirfairelinux.com> <20150618011159.GA22072@lunn.ch> <2144581324.52952.1434726314482.JavaMail.zimbra@savoirfairelinux.com> <20150619150533.GH3557@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:63294 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbbFSPsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 11:48:31 -0400
In-Reply-To: <20150619150533.GH3557@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Jun 19, 2015, at 11:05 AM, Andrew Lunn andrew@lunn.ch wrote:
>> Yes I do have debug too, but via sysfs (with eventually write access) for:
>> GLOBAL1, GLOBAL2, cpu port registers, SerDes registers, PVIDs, and VTU.
>> Not really standard though.
> 
> We should really get an implementation into mainline. There is no
> point us all implementing our own.

I couldn't agree more. It's important for development to have read/write
access to the switch registers, bypassing the userspace tools.

> You say your code is not really standard. Do you think it would get
> rejected if it was submitted? The rules for debugfs are much more
> relaxed, so what i have should be acceptable.

Yes my code will definitely be rejected. I have a net/dsa/debug.c file
that creates a debug directory under /sys/devices/platform/dsa.0/ with
global1, global2, cpu_port, serdes, pvid, and vtu sysfs attributes.

Read and write access to debugfs sounds better IMO.

Thanks,
-v
