From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 0/4] mv643xx_eth: use mvmdio MDIO bus driver
Date: Fri, 15 Mar 2013 13:51:01 +0100
Message-ID: <51431935.6060407@openwrt.org>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org> <1363284515-9865-1-git-send-email-florian@openwrt.org> <20130315.085321.1047694772636447477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	rob@landley.net, jason@lakedaemon.net, andrew@lunn.ch,
	linux@arm.linux.org.uk, benh@kernel.crashing.org, paulus@samba.org,
	buytenh@wantstofly.org, thomas.petazzoni@free-electrons.com,
	gregkh@linuxfoundation.org, devicetree-discuss@lists.ozlabs.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130315.085321.1047694772636447477.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/15/13 13:53, David Miller a =C3=A9crit :
> From: Florian Fainelli <florian@openwrt.org>
> Date: Thu, 14 Mar 2013 19:08:31 +0100
>
>> This patch converts the mv643xx_eth driver to use the mvmdio MDIO bu=
s driver
>> instead of rolling its own implementation. As a result, all users of=
 this
>> mv643xx_eth driver are converted to register an "orion-mdio" platfor=
m_device.
>> The mvmdio driver is also updated to support an interrupt line which=
 reports
>> SMI error/completion, and to allow traditionnal platform device regi=
stration
>> instead of just device tree.
>>
>> David, I think it makes sense for you to merge all of this, since we=
 do
>> not want the architecture files to be desynchronized from the mv643x=
x_eth to
>> avoid runtime breakage. The potential for merge conflicts should be =
very small.
>
> All applied to net-next, thanks.
>

Oh woah that was fast, maybe too fast, I will submit a follow-up patch=20
for patch 4 to address the issues I mentionned earlier.
--
=46lorian
