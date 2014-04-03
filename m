From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 20:20:45 +0200
Message-ID: <533DA67D.50806@ahsoftware.de>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de> <533C8ECB.4090900@gmail.com> <533D0B09.9040602@ahsoftware.de> <533D207E.9020909@gmail.com> <533D790C.5000104@ahsoftware.de> <533D9DE5.3000605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <533D9DE5.3000605@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 03.04.2014 19:44, schrieb Sebastian Hesselbarth:

> I tried to reproduce the regression on Dockstar with 3.14.0 and
> 3.14.0-07247-gcd6362be, netconsole enabled, DHCP (dhclient).

Try using dhcpcd, that's why I mentioned it. DHCP-clients do work 
differently.

> I can neither reproduce any issues with ethernet before nor after
> dhclient kicks in. I can also use netconsole just fine and see
> plenty of kernel bootlog messages sent to netconsole receiver.
>
> Can you _please_ share a full report how to properly reproduce it?

Impossible because timing and other stuff (boot media, switch, 
type/version of iproute, dhcp-client, ...) might be involved.

Alexander Holler

BTW: if you want to fix another bug, changing the mtu does reset the 
ethernet device. Something special for mv643xx_eth and not very nice. ;)
