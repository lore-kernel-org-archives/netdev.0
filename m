From: "cramerj" <cramerj@intel.com>
Subject: RE: [PATCH] e1000: ethtool cleanups
Date: Wed, 5 Jan 2005 16:36:31 -0800
Message-ID: <76FA8CF8F1F53240BB5B962A3385A58001EBD04C@orsmsx405>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> +		if (hw->media_type == e1000_media_type_fiber)
> +			hw->autoneg_advertised =
ADVERTISED_100baseT_Full |

should be ADVERTISED_1000baseT_Full
                        ^

Looks good.

Thanks,
-Jeb
