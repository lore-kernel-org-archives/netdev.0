From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 00/14] net: dsa: Fixes and enhancements
Date: Wed, 22 Oct 2014 21:45:41 -0700
Message-ID: <CAGVrzcbohXf09pvrzayZEfcpjr8U-h-hyuYMnU0yTBJny0U27A@mail.gmail.com>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-10-22 21:03 GMT-07:00 Guenter Roeck <linux@roeck-us.net>:
> Patch 01/14 addresses an annoying and unhelpful log message.
>
> Patches 02/14 and 03/14 are minor enhancements, adding support for
> known switch revisions.
>
> Patches 04/14 and 05/14 add support for MV88E6352 and MV88E6176.
>
> Patch 06/14 adds support for hardware monitoring, specifically for
> reporting the chip temperature, to the dsa subsystem.
>
> Patches 07/14 and 08/14 implement hardware monitoring for MV88E6352,
> MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
>
> Patch 09/14 adds support for EEPROM access to the DSA subsystem.
>
> Patch 10/14 implements EEPROM access for MV88E6352 and MV88E6176.
>
> Patch 11/14 adds support for reading switch registers to the DSA
> subsystem.
>
> Patches 12/14 amd 13/14 implement support for reading switch registers
> to the drivers for MV88E6352, MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
>
> Patch 14/14 adds support for reading additional RMON registers to the drivers
> for  MV88E6352, MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
>
> The series resides and was tested on top of v3.18-rc1 in a system
> with MV88E6352. Testing in systems with 88E6131, 88E6060 and MV88E6165
> was done earlier (I don't have access to those systems right now).
> The series applies cleanly to net-next as of today (10/22).

Besides the two nitpicking comments, this looks really good to me, thanks!

>
> ----------------------------------------------------------------
> Guenter Roeck (14):
>       net: dsa: Don't set skb->protocol on outgoing tagged packets
>       net: dsa: Report known silicon revisions for Marvell 88E6060
>       net: dsa: Report known silicon revisions for Marvell 88E6131
>       net: dsa: Add support for Marvell 88E6352
>       net: dsa/mv88e6352: Add support for MV88E6176
>       net: dsa: Add support for hardware monitoring
>       net: dsa/mv88e6352: Report chip temperature
>       net: dsa/mv88e6123_61_65: Report chip temperature
>       net: dsa: Add support for switch EEPROM access
>       net: dsa/mv88e6352: Implement EEPROM access functions
>       net: dsa: Add support for reading switch registers with ethtool
>       net: dsa/mv88e6123_61_65: Add support for reading switch registers
>       net: dsa/mv88e6352: Add support for reading switch registers
>       net: dsa: Provide additional RMON statistics
>
>  MAINTAINERS                       |   5 +
>  drivers/net/dsa/Kconfig           |   9 +
>  drivers/net/dsa/Makefile          |   3 +
>  drivers/net/dsa/mv88e6060.c       |   5 +-
>  drivers/net/dsa/mv88e6123_61_65.c |  68 +++-
>  drivers/net/dsa/mv88e6131.c       |  12 +-
>  drivers/net/dsa/mv88e6352.c       | 789 ++++++++++++++++++++++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx.c       |  53 ++-
>  drivers/net/dsa/mv88e6xxx.h       |  15 +
>  include/net/dsa.h                 |  20 +
>  net/dsa/dsa.c                     | 111 ++++++
>  net/dsa/slave.c                   |  60 +++
>  net/dsa/tag_dsa.c                 |   2 -
>  net/dsa/tag_edsa.c                |   2 -
>  net/dsa/tag_trailer.c             |   2 -
>  15 files changed, 1138 insertions(+), 18 deletions(-)
>  create mode 100644 drivers/net/dsa/mv88e6352.c



-- 
Florian
