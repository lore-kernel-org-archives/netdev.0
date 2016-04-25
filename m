From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Mon, 25 Apr 2016 15:16:40 +0200
Message-ID: <20160425131640.GD6575@lunn.ch>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com>
 <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com>
 <571915F5.5070504@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, bjorn.andersson@linaro.org,
	Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <571915F5.5070504@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Does the compatible property of the phy node (for the external phy)
> need to list the actual external phy?  That is, should it look like
> this:
> 
> 	phy0: ethernet-phy@0 {
> 		compatible = "qcom,fsm9900-emac-phy";
> 		reg = <0>;
> 	}
> 
> or this:
> 
> 	phy0: ethernet-phy@0 {
> 		compatible = "athr,whatever-phy";
> 		reg = <0>;
> 	}
> 

Documentation/devicetree/bindings/net/phy.txt says:

Optional Properties:

- compatible: Compatible list, may contain
  "ethernet-phy-ieee802.3-c22" or "ethernet-phy-ieee802.3-c45" for
  PHYs that implement IEEE802.3 clause 22 or IEEE802.3 clause 45
  specifications. If neither of these are specified, the default is to
  assume clause 22.

  If the phy's identifier is known then the list may contain an entry
  of the form: "ethernet-phy-idAAAA.BBBB" where
     AAAA - The value of the 16 bit Phy Identifier 1 register as
            4 hex digits. This is the chip vendor OUI bits 3:18
     BBBB - The value of the 16 bit Phy Identifier 2 register as
            4 hex digits. This is the chip vendor OUI bits 19:24,
            followed by 10 bits of a vendor specific ID.

  The compatible list should not contain other values than those
  listed here.

  Andrew
