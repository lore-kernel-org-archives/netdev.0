From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3] Documentation: devicetree: add qca8k binding
Date: Mon, 12 Sep 2016 14:53:19 +0300
Message-ID: <c6c64bcc-50ad-0cbb-3e56-0f8dab45c413@cogentembedded.com>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-2-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com, devicetree@vger.kernel.org
To: John Crispin <john@phrozen.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473669337-21221-2-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/12/2016 11:35 AM, John Crispin wrote:

> Add device-tree binding for ar8xxx switch families.
>
> Cc: devicetree@vger.kernel.org
> Signed-off-by: John Crispin <john@phrozen.org>
> ---
>  .../devicetree/bindings/net/dsa/qca8k.txt          |   53 ++++++++++++++++++++
>  1 file changed, 53 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/qca8k.txt
>
> diff --git a/Documentation/devicetree/bindings/net/dsa/qca8k.txt b/Documentation/devicetree/bindings/net/dsa/qca8k.txt
> new file mode 100644
> index 0000000..2a1ad06
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/qca8k.txt
> @@ -0,0 +1,53 @@
> +* Qualcomm Atheros QCA8xxx switch family
> +
> +Required properties:
> +
> +- compatible: should be "qca,qca8337"
> +- #size-cells: must be 0
> +- #address-cells: must be 1
> +
> +Subnodes:
> +
> +The integrated switch subnode should be specified according to the binding
> +described in dsa/dsa.txt.
> +
> +Example:
> +
> +	&mdio0 {
> +		switch@0 {
> +			compatible = "qca,qca8337";
> +
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <30>;
> +
> +			ports {
> +				port@0 {
> +					reg = <11>;
> +					label = "cpu";
> +					ethernet = <&gmac1>;
> +					phy-mode = "rgmii";
> +				};
> +
> +				port@1 {
> +					reg = <0>;
> +					label = "lan1";
> +				};
> +
> +				port@2 {
> +					reg = <1>;
> +					label = "lan2";
> +				};
> +
> +				port@3 {
> +					reg = <2>;
> +					label = "lan3";
> +				};
> +
> +				port@4 {
> +					reg = <3>;
> +					label = "lan4";
> +				};

    The <unit-address> part of the node name should correspond to the "reg" 
prop. I think modern 'dtc' even warns about that...

[...]

MBR, Sergei
