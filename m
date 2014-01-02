From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: question about tulip/winbond-840.c
Date: Thu, 2 Jan 2014 08:53:07 -0800
Message-ID: <CAP6odjiCpBxAhWrMLjTQTwnwNsBiFo5ojDpFo+MPpT0Jd8xyNw@mail.gmail.com>
References: <alpine.DEB.2.10.1401021520280.2088@hadrien>
	<CAP6odjj2jPfgEBdHv+GGDhVaHt4KEm_DWCX3PdCxCjUbApWc8Q@mail.gmail.com>
	<alpine.DEB.2.10.1401021641230.2088@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:33488 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaABQxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 11:53:08 -0500
Received: by mail-oa0-f49.google.com with SMTP id i4so14966485oah.22
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 08:53:07 -0800 (PST)
In-Reply-To: <alpine.DEB.2.10.1401021641230.2088@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 8:16 AM, Julia Lawall <julia.lawall@lip6.fr> wrote:
...
> It does set up more things.  But it doesn't do much if the device has not
> been disabled.
> http://lxr.free-electrons.com/source/drivers/pci/pci.c#L1190

Sure...but this driver _should_ disable on suspend. But who knows...my
guess is that if anyone has tried suspending this device, it works
anyway on resume.

> Looking across the entire Linux kernel, I see cases where there are
> enables but no disables, and cases where there are disables and no
> enables.  So I wouldn't really know whether a change is needed.

I think both cases are wrong. I'm pretty sure enable/disable should be
symmetric for both "init_one/remove_one"  and suspend/resume.  I'm not
aware of any reason why they would not be.

cheers,
grant
