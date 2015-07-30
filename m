From: Radha Mohan <mohun106@gmail.com>
Subject: Re: [PATCH v2 0/3] Add MDIO support to ThunderX NIC driver
Date: Wed, 29 Jul 2015 17:01:06 -0700
Message-ID: <CAC8NTUXy0Man6QvxgRJW-B4KPxrrzK5ngDAAZX8PB5nPwBKYVQ@mail.gmail.com>
References: <1438121533-21528-1-git-send-email-mohun106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Daney <ddaney@caviumnetworks.com>,
	sgoutham@caviumnetworks.com,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438121533-21528-1-git-send-email-mohun106@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 28, 2015 at 3:12 PM,  <mohun106@gmail.com> wrote:
> From: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
>
> This patch series adds MDIO support to ThunderX NIC driver by making use
> of existing mdio-octeon driver. In the process modified the mdio-octeon
> driver to work on both Octeon and ThunderX platforms.
>
> * From v1:
>   - Removed default selection in Kconfig for MDIO_OCTEON
>   - Replace uint64 with u64 as suggested by David Daney
>
> Radha Mohan Chintakuntla (3):
>   net: mdio-octeon: Modify driver to work on both ThunderX and Octeon
>   net: mdio-octeon: Fix octeon_mdiobus_probe function for return values
>   net: thunderx: Select CONFIG_MDIO_OCTEON for ThunderX NIC
>
>  drivers/net/ethernet/cavium/Kconfig |    2 +
>  drivers/net/phy/Kconfig             |   10 ++--
>  drivers/net/phy/mdio-octeon.c       |  136 +++++++++++++++++++++++++++++------
>  3 files changed, 122 insertions(+), 26 deletions(-)
>

Cc'ing David Miller.
Can you pick this patch series please ?
