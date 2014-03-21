From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 1/3] Documentation: add Device tree bindings for Hisilicon
 hip04 ethernet
Date: Fri, 21 Mar 2014 21:04:00 +0800
Message-ID: <CAMj5BkjqXow9ckfg_Z+U-TnK151px3fYP3ME8=R=Dt6+qTiUiQ@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
	<1395132017-15928-2-git-send-email-zhangfei.gao@linaro.org>
	<53284138.9030809@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:44450 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760098AbaCUNEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 09:04:02 -0400
In-Reply-To: <53284138.9030809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sergei

Thanks for the kind suggestion, will update.

On Tue, Mar 18, 2014 at 8:51 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:

>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
>> b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
>> new file mode 100644
>> index 0000000..c918f08
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
>> @@ -0,0 +1,74 @@
>> +Hisilicon hip04 Ethernet Controller
>> +
>> +* Ethernet controller node
>> +
>> +Required properties:
>> +- compatible: should be "hisilicon,hip04-mac".
>> +- reg: address and length of the register set for the device.
>> +- interrupts: interrupt for the device.
>> +- port: ppe port number connected to the controller: range from 0 to 31.
>> +- speed: 100 (100M) or 1000 (1000M).
>
>
>    There's standard "max-speed" property for that, see
> Documentation/devicetree/bindings/net/ethernet.txt in the 'net-next.git'
> repo.
>
>
>> +Optional Properties:
>> +- phy-handle : the phandle to a PHY node
>
>
>    Please refer instead to the above mentioned file for this standard
> property -- it is already described there. See other binding files as the
> example.

Yes, Documentation/devicetree/bindings/net/ethernet.txt has defined
many useful node.
Will refer it directly.

Thanks
