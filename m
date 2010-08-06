From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of pseduo-platform
	busses
Date: Fri, 6 Aug 2010 09:12:27 -0600
Message-ID: <AANLkTi=VbVed09=u-Ea0L8c_CWZ_CLLjWH9ZjD2dyg6Y@mail.gmail.com>
References: <4C58A7AA.8020007@codeaurora.org> <20100803235631.GA17759@suse.de>
	<4C58AE15.6090900@codeaurora.org> <20100804000945.GA19729@suse.de>
	<4C58B1B6.9050005@quicinc.com> <AANLkTikVzh9=DvvUPbKmDeo6k2-pPVSnjH+GxAPdQFO4@mail.gmail.com>
	<20100806142727.GB4921@suse.de>
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
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45712 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756385Ab0HFPMs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 11:12:48 -0400
In-Reply-To: <20100806142727.GB4921@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 6, 2010 at 8:27 AM, Greg KH <gregkh@suse.de> wrote:
> On Thu, Aug 05, 2010 at 04:59:35PM -0600, Grant Likely wrote:
>> (On that point Greg, what is the reason for even having the
>> /sys/devices/platform/ parent? =A0Why not just let the platform devi=
ces
>> sit at the root of the device tree? =A0In the OF case (granted, I'm
>> biased) all of the platform_device registrations reflect the actual
>> device hierarchy expressed in the device tree data.)
>
> If we sat them at the "root", there would be a bunch of them there. =A0=
I
> don't know, we could drop the parent, I guess whoever created the
> platform device oh so long ago, decided that it would look nicer to b=
e
> in this type of structure.

Personally I'd rather see a meaningful structure used here.  Maybe
having them all in the root will encourage people to find realistic
parents for their platform devices.  :-)  Why don't I float a patch to
remove this and see if anybody freaks out.  Should I wrap it with a
CONFIG_ so that it can be configurable for a release or to, or just
make it unconditional?

>> Now, having gone on this whole long tirade, it looks like having
>> separate platform bus types may not be the best approach after all.
>
> I totally agree, and thanks for the detailed explaination, it saved m=
e
> from having to write up the same thing :)

:-)

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
