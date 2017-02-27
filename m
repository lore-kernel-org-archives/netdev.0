From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH net-next 4/6] drivers: net: xgene-v2: Add base driver
Date: Sun, 26 Feb 2017 20:33:23 -0800
Message-ID: <CAKh23FnRaGh0Hg0a1mb12CirEtW3RDdj=01-3RKGqycQP6H+Lw@mail.gmail.com>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
 <1485889401-13909-5-git-send-email-isubramanian@apm.com>
 <20170131200149.GM5656@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Keyur Chudgar <kchudgar@apm.com>,
 patches <patches@apm.com>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170131200149.GM5656@lunn.ch>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Tue, Jan 31, 2017 at 12:01 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> +     phy_mode = device_get_phy_mode(dev);
>> +     if (phy_mode < 0) {
>> +             dev_err(dev, "Unable to get phy-connection-type\n");
>> +             return phy_mode;
>> +     }
>> +     pdata->resources.phy_mode = phy_mode;
>> +
>> +     if (pdata->resources.phy_mode != PHY_INTERFACE_MODE_RGMII) {
>> +             dev_err(dev, "Incorrect phy-connection-type specified\n");
>> +             return -ENODEV;
>> +     }
>
> This seems a bit limiting. What if you need to use:
>
> PHY_INTERFACE_MODE_RGMII_ID,
> PHY_INTERFACE_MODE_RGMII_RXID,
> PHY_INTERFACE_MODE_RGMII_TXID,
>
> in order to set the RGMII delays.

This version of the driver doesn't support setting delays.  The delay
support will be added in the future.

>
>    Andrew
>
