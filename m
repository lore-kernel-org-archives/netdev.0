From: Olof Johansson <olof@lixom.net>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 10:14:00 -0800
Message-ID: <CAOesGMi+ymn_FdDfgTjwgyO-MsEJNGBDU9ayRJvGkjJ7T_ExfA@mail.gmail.com>
References: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
	<20160126044624.GH3880@lunn.ch>
	<20160126121435.GK22974@ak-desktop.emea.nsn-net.net>
	<20160126133417.GI3880@lunn.ch>
	<CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com>
	<20160126175353.GG27473@lunn.ch>
	<CAOesGMhYU4NOeGRJoF4bcELCFfSsvBVp2du7ZgVjC3QuCv637w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aaro Koskinen <aaro.koskinen@nokia.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33011 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756365AbcAZSOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 13:14:01 -0500
Received: by mail-yk0-f181.google.com with SMTP id k129so210807311yke.0
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 10:14:01 -0800 (PST)
In-Reply-To: <CAOesGMhYU4NOeGRJoF4bcELCFfSsvBVp2du7ZgVjC3QuCv637w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+devicetree@vger.kernel.org instead.

On Tue, Jan 26, 2016 at 10:08 AM, Olof Johansson <olof@lixom.net> wrote:
> On Tue, Jan 26, 2016 at 9:53 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>>> I hate to bikeshed, but I'm not sure if "generic-mdio" is too...
>>> generic? Will someone writing a DT be thinking "well, this is a
>>> generic mdio PHY, I should set it"?  "mdio-device"?
>>> "generic-nonphy-mdio"? Neither of those seem much better.
>>
>> How about 'not-a-phy'?
>
> "mdio,not-a-phy" or "mdio,non-phy" will scope it a bit, especially if
> you expect other generic mdio properties that can do with a namespace.
>
> Probably time to add devicetree-discuss. Doing so.
>
>
> -Olof
