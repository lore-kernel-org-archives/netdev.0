From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net v1 1/2] ARM: dts: imx: let's name the ptp interrupt
 for the fec ethernet driver
Date: Tue, 3 Oct 2017 13:41:34 -0700
Message-ID: <b07b44ca-3804-bd7d-900c-556443a02ac8@boundarydevices.com>
References: <20171003000442.31841-1-troy.kisky@boundarydevices.com>
 <20171003005148.GA24147@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, fugang.duan@nxp.com, netdev@vger.kernel.org,
        davem@davemloft.net, fabio.estevam@nxp.com, lznuaa@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:54236 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751115AbdJCUla (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 16:41:30 -0400
Received: by mail-oi0-f52.google.com with SMTP id j126so16401454oia.10
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 13:41:30 -0700 (PDT)
In-Reply-To: <20171003005148.GA24147@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/2017 5:51 PM, Andrew Lunn wrote:
> On Mon, Oct 02, 2017 at 05:04:41PM -0700, Troy Kisky wrote:
>> imx7s/imx7d has the ptp interrupt newly added as well.
>> This will allow the ptp interrupt to have its own interrupt routine.
>>
>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>> ---
>>  arch/arm/boot/dts/imx6qdl.dtsi | 1 +
>>  arch/arm/boot/dts/imx6sx.dtsi  | 2 ++
>>  arch/arm/boot/dts/imx6ul.dtsi  | 2 ++
>>  arch/arm/boot/dts/imx7d.dtsi   | 4 +++-
>>  arch/arm/boot/dts/imx7s.dtsi   | 4 +++-
>>  5 files changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm/boot/dts/imx6qdl.dtsi b/arch/arm/boot/dts/imx6qdl.dtsi
>> index 8884b4a3cafb..d848d2bfe8e2 100644
>> --- a/arch/arm/boot/dts/imx6qdl.dtsi
>> +++ b/arch/arm/boot/dts/imx6qdl.dtsi
>> @@ -1017,6 +1017,7 @@
>>  			fec: ethernet@02188000 {
>>  				compatible = "fsl,imx6q-fec";
>>  				reg = <0x02188000 0x4000>;
>> +				interrupt-names = "","ptp";
> 
> Hi Troy
> 
> The "" looks a bit odd. Can you use a name here?
> 
>     Andrew
> 

Sure. Can I use "q0","q1","q2",  and look them up by name in fec_main
as well ?

Should I worrying about compatiblity with old dtbs ?
I could look up by number if name fails. Maybe with a
deprecated warning ?


Thanks
Troy
