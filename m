From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller driver
Date: Thu, 14 Apr 2016 12:18:38 -0500
Message-ID: <CAL_Jsq+pc7WAuDfYCLe111HmnsLGY61K0S3rm2_XdK8xvO_fLg@mail.gmail.com>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <20160414163240.GB15303@rob-hp-laptop> <570FC987.80304@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	Christopher Covington <cov@codeaurora.org>,
	Gilad Avidov <gavidov@codeaurora.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Bjorn Andersson <bjorn.andersson@linaro.org>,
	Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <570FC987.80304@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2016 at 11:47 AM, Timur Tabi <timur@codeaurora.org> wrote:
> Rob Herring wrote:
>
>>> @@ -0,0 +1,65 @@
>>> +Qualcomm EMAC Gigabit Ethernet Controller
>>> +
>>> +Required properties:
>>> +- compatible : Should be "qcom,emac".
>>
>>
>> Come on... Can you guess what I'm going to say here.
>
>
> Ooops, I missed that one.
>
>>
>>> +- reg : Offset and length of the register regions for the device
>>> +- reg-names : Register region names referenced in 'reg' above.
>>> +       Required register resource entries are:
>>> +       "base"   : EMAC controller base register block.
>>> +       "csr"    : EMAC wrapper register block.
>>> +       Optional register resource entries are:
>>> +       "ptp"    : EMAC PTP (1588) register block.
>>> +                  Required if 'qcom,emac-tstamp-en' is present.
>>> +       "sgmii"  : EMAC SGMII PHY register block.
>>> +- interrupts : Interrupt numbers used by this controller
>>> +- interrupt-names : Interrupt resource names referenced in 'interrupts'
>>> above.
>>> +       Required interrupt resource entries are:
>>> +       "emac_core0"   : EMAC core0 interrupt.
>>> +       "sgmii_irq"   : EMAC SGMII interrupt.
>>> +- phy-addr            : Specifies phy address on MDIO bus.
>>> +                       Required if the optional property
>>> "qcom,no-external-phy"
>>> +                       is not specified.
>>
>>
>> As I mentioned in the last version, you should still describe this with
>> a standard MDIO bus binding even if you can't use the generic code.
>
>
> You mean like this?
>
>         phy0: ethernet-phy@0 {
>                 compatible = "qcom,fsm9900-emac-phy";
>                 reg = <4>;

Yes, but you mean 0 here or 4 for unit address.
