From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 3/4] dt-bindings: can: m_can: Include reference to new
 fixed transceiver binding
Date: Thu, 3 Aug 2017 12:20:20 +0300
Message-ID: <53a5346e-9c04-738e-432c-16cdcc4c6e60@cogentembedded.com>
References: <20170803005150.9286-1-fcooper@ti.com>
 <20170803005150.9286-4-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper@ti.com>,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org,
        quentin.schulz@free-electrons.com, dev.kurt@vandijck-laurijssen.be,
        andrew@lunn.ch, socketcan@hartkopp.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803005150.9286-4-fcooper@ti.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/3/2017 3:51 AM, Franklin S Cooper Jr wrote:

> Add information regarding fixed transceiver binding. This is especially
> important for MCAN since the IP allows CAN FD mode to run significantly
> faster than what most transceivers are capable of.
> 
> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
> ---
>   Documentation/devicetree/bindings/net/can/m_can.txt | 9 +++++++++
>   1 file changed, 9 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/can/m_can.txt b/Documentation/devicetree/bindings/net/can/m_can.txt
> index 9e33177..0b62f47 100644
> --- a/Documentation/devicetree/bindings/net/can/m_can.txt
> +++ b/Documentation/devicetree/bindings/net/can/m_can.txt
> @@ -43,6 +43,11 @@ Required properties:
>   			  Please refer to 2.4.1 Message RAM Configuration in
>   			  Bosch M_CAN user manual for details.
>   
> +Optional properties:
> +- fixed-transceiver	: Fixed-transceiver subnode describing maximum speed

    Subnode is not a property.

> +			  that can be used for CAN/CAN-FD modes. See
> +			  Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
> +			  for details.
>   Example:
>   SoC dtsi:
>   m_can1: can@020e8000 {
> @@ -64,4 +69,8 @@ Board dts:
>   	pinctrl-names = "default";
>   	pinctrl-0 = <&pinctrl_m_can1>;
>   	status = "enabled";
> +
> +	fixed-transceiver@0 {

    Same comments here as in previous patch.

[...]

MBR, Sergei
