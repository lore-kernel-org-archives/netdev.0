From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: SoCFPGA ethernet broken
Date: Thu, 15 Oct 2015 22:04:04 -0500
Message-ID: <alpine.DEB.2.02.1510152149290.22844@linux-builds1>
References: <561FF9E2.30102@opensource.altera.com> <56200687.9040903@gmail.com> <562005AD.8020903@opensource.altera.com> <56200BD7.8020505@gmail.com> <56200E15.9080603@caviumnetworks.com> <56201158.8040806@opensource.altera.com>
 <56201AE7.2020103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Daney <ddaney@caviumnetworks.com>,
	"David S. Miller" <davem@davemloft.net>, <david.daney@cavium.com>,
	<netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56201AE7.2020103@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Oct 2015, Florian Fainelli wrote:

> On 15/10/15 13:49, Dinh Nguyen wrote:
> >>
> >> Does this text change with and without the 8b63ec1837fa patch?
> > 
> > No, this text does not change with/without the 8b63ec1837fa patch.
> 
> Could you instrument mdiobus_scan(), get_phy_device() and
> phy_device_create/register to see if the parent is NULL, non-NULL?
> 

[    0.800479] get_phy_device bus=0xeee26c00 addr=00000004 phy_id=00221611
[    0.806735] phy_device_create dev->dev.parent=0xeee26c50
[    0.811114] phy_device_register completed
[    0.814675] mdiobus_scan phydev=0xeee27000
[    1.979034] ksz9021_config_init of_node=00000000

---- Without patch ----

[    0.801294] get_phy_device bus=0xeeef6c00 addr=00000004 phy_id=00221611
[    0.807551] phy_device_create dev->dev.parent=0xeed6cc10
[    0.811929] phy_device_register completed
[    0.815510] mdiobus_scan phydev=0xeeef7000
[    1.979034] ksz9021_config_init of_node=0xef203538
[    1.988064] ksz9021_load_values_from_of
[    1.992485] ksz9021_load_values_from_of
[    1.996905] ksz9021_load_values_from_of 

BR,
Dinh
