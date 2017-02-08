From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Kernel crashes in phy_attach_direct()
Date: Wed, 8 Feb 2017 12:34:19 -0200
Message-ID: <CAOMZO5BzLh4az9t=fJkG80GW3_xdD3YxUbagL4dJp7Hwr4koZw@mail.gmail.com>
References: <CAOMZO5C58--W1q+i26-+DBcton0Bk_o3zVfyuumM+Y=OemQ_Aw@mail.gmail.com>
 <20170208142857.GD10855@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f171.google.com ([74.125.82.171]:36031 "EHLO
        mail-ot0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753754AbdBHOev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 09:34:51 -0500
Received: by mail-ot0-f171.google.com with SMTP id 32so114017250oth.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 06:34:20 -0800 (PST)
In-Reply-To: <20170208142857.GD10855@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Wed, Feb 8, 2017 at 12:28 PM, Andrew Lunn <andrew@lunn.ch> wrote:

> Hi Fabio
>
> Could you try reverting:
>
> commit cafe8df8b9bc9aa3dffa827c1a6757c6cd36f657
> Author: Mao Wenan <maowenan@huawei.com>
> Date:   Tue Jan 31 18:46:43 2017 -0800
>
>     net: phy: Fix lack of reference count on PHY driver
>
>     There is currently no reference count being held on the PHY driver,
>     which makes it possible to remove the PHY driver module while the PHY
>     state machine is running and polling the PHY. This could cause crashes
>     similar to this one to show up:

Yes, after reverting this commit I no longer get the kernel crash.

Thanks
