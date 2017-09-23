From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Add basic offloading of
 unicast traffic
Date: Sat, 23 Sep 2017 16:31:23 +0200
Message-ID: <20170923143123.GA21228@lunn.ch>
References: <20170921094139.4250-1-privat@egil-hjelmeland.no>
 <20170921094139.4250-3-privat@egil-hjelmeland.no>
 <20170921142127.GB27589@lunn.ch>
 <b27d2dd4-84e3-b930-a6fe-1e5b36a7d213@egil-hjelmeland.no>
 <20170922200810.GJ3470@lunn.ch>
 <2c5fec6d-18b3-97e9-dd64-85560382d2f7@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2c5fec6d-18b3-97e9-dd64-85560382d2f7@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The point is: Once both external ports are in "forwarding", I see no way
> to prevent traffic flowing directly between the external ports.

Generally, there are port vectors. Port X can send frames only to Port
Y.

If you don't have that, there are possibilities with VLANs. Each port
is given a unique VLAN. All incoming untagged traffic is tagged with
the VLAN. You just need to keep the VLAN separated and add/remove the
VLAN tag in the dsa tag driver.

     Andrew
