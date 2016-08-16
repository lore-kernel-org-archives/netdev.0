From: Shubhrajyoti Datta <shubhrajyoti.datta@gmail.com>
Subject: Re: [PATCH RFCv2] net: ethernet: macb: Add support for rx_clk
Date: Tue, 16 Aug 2016 10:16:50 +0530
Message-ID: <CAKfKVtHMB4mHJMOnfLaGiArCJJ9VQ9-gCbLPXj1COO9L8adi5g@mail.gmail.com>
References: <1470996979-33015-1-git-send-email-shubhrajyoti.datta@xilinx.com> <20160812190318.GA17752@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	=?UTF-8?Q?S=C3=B6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33000 "EHLO
	mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcHPEqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 00:46:52 -0400
In-Reply-To: <20160812190318.GA17752@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,
Thanks for the review.

On Sat, Aug 13, 2016 at 12:33 AM, Rob Herring <robh@kernel.org> wrote:
> On Fri, Aug 12, 2016 at 03:46:19PM +0530, Shubhrajyoti Datta wrote:
>> Some of the platforms like zynqmp ultrascale+ has a
>> separate clock gate for the rx clock. Add an optional
>> rx_clk so that the clock can be enabled.
>>
>> Signed-off-by: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>
>> ---
>> v2:
>> fix warning
>>
>>  Documentation/devicetree/bindings/net/macb.txt |  2 +-
>>  drivers/net/ethernet/cadence/macb.c            | 31 +++++++++++++++++++++-----
>>  drivers/net/ethernet/cadence/macb.h            |  4 +++-
>>  3 files changed, 30 insertions(+), 7 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
>> index b5a42df..315beda 100644
>> --- a/Documentation/devicetree/bindings/net/macb.txt
>> +++ b/Documentation/devicetree/bindings/net/macb.txt
>> @@ -20,7 +20,7 @@ Required properties:
>>  - phy-mode: See ethernet.txt file in the same directory.
>>  - clock-names: Tuple listing input clock names.
>>       Required elements: 'pclk', 'hclk'
>> -     Optional elements: 'tx_clk'
>> +     Optional elements: 'tx_clk', 'rx_clk'
>
> Please state which compatibles this applies to.

will fix in the next version

>
>>  - clocks: Phandles to input clocks.
>>
>>  Optional properties for PHY child node:
