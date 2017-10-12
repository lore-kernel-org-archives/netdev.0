From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 12:06:50 -0700 (PDT)
Message-ID: <20171012.120650.1063812043202847517.davem@davemloft.net>
References: <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
        <20171012150419.GI14672@nanopsycho>
        <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
        steven.lin1@broadcom.com, netdev@vger.kernel.org,
        jiri@mellanox.com, michael.chan@broadcom.com,
        linux-pci@vger.kernel.org, linville@tuxdriver.com,
        gospo@broadcom.com
To: f.fainelli@gmail.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 12 Oct 2017 08:43:59 -0700

> Once we move ethtool (or however we name its successor) over to
> netlink there is an opportunity for accessing objects that do and do
> not have a netdevice representor today (e.g: management ports on
> switches) with the same interface, and devlink could be used for
> that.

That is an interesting angle for including this in devlink.

I'm not so sure what to do about this.

One suggestion is that devlink is used for getting ethtool stats for
objects lacking netdev representor's, and a new genetlink family is
used for netdev based ethtool.

I think it's important that we don't expand the scope of devlink
beyond what it was originally designed for.
