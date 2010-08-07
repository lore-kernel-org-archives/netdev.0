From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of pseduo-platform
	busses
Date: Sat, 7 Aug 2010 11:28:13 -0600
Message-ID: <AANLkTimjXd=SL61KvjDfvJ-JtXsSVW9pwOYBFUHX0mVp@mail.gmail.com>
References: <4C58A7AA.8020007@codeaurora.org> <20100803235631.GA17759@suse.de>
	<4C58AE15.6090900@codeaurora.org> <20100804000945.GA19729@suse.de>
	<4C58B1B6.9050005@quicinc.com> <AANLkTikVzh9=DvvUPbKmDeo6k2-pPVSnjH+GxAPdQFO4@mail.gmail.com>
	<20100806142727.GB4921@suse.de> <AANLkTi=VbVed09=u-Ea0L8c_CWZ_CLLjWH9ZjD2dyg6Y@mail.gmail.com>
	<20100806234635.GC16793@suse.de> <AANLkTimHbcF+fz=aBMLdhLo2s-rhfNvaPCtqE8nYJ8aT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Pannuto <ppannuto@quicinc.com>,
	Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>, "dtor@mail.ru" <dtor@mail.ru>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kevin Hilman <khilman@deeprootsystems.com>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43211 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab0HGR2e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Aug 2010 13:28:34 -0400
In-Reply-To: <AANLkTimHbcF+fz=aBMLdhLo2s-rhfNvaPCtqE8nYJ8aT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 7, 2010 at 12:35 AM, Grant Likely <grant.likely@secretlab.c=
a> wrote:
> On Fri, Aug 6, 2010 at 5:46 PM, Greg KH <gregkh@suse.de> wrote:
>> That would be nice, but take your "standard" PC today:
>> =A0 =A0 =A0 =A0> ls /sys/devices/platform/
>> =A0 =A0 =A0 =A0Fixed MDIO bus.0 =A0i8042 =A0pcspkr =A0power =A0seria=
l8250 =A0uevent vesafb.0
>>
>> There are tty devices below the serial port, which is nice to see, b=
ut
>> the others? =A0I don't know what type of bus they would be on, do yo=
u?
[...]
> I wouldn't have any problem modifying those specific drivers to
> register under something like /sys/devices/legacy, but I don't really
> think it is in any way necessary.

Or for that matter, make those drivers explicitly use
/sys/devices/platform so that I don't cause churn on PCs.  :-)  I'd
like to be rid of it as default behaviour for embedded though.

g.
