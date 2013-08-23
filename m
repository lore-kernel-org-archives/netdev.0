From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 11:54:45 -0400
Message-ID: <521785C5.9000903@ti.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-4-git-send-email-zonque@gmail.com> <52177052.1030308@ti.com> <52177E29.6040103@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <zonque@gmail.com>, <netdev@vger.kernel.org>,
	<nsekhar@ti.com>, <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<mugunthanvnm@ti.com>, <vaibhav.bedia@ti.com>, <d-gerlach@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Benoit Cousson <bcousson@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:59603 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755681Ab3HWPzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 11:55:16 -0400
In-Reply-To: <52177E29.6040103@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 23 August 2013 11:22 AM, Benoit Cousson wrote:
> Hi Santosh,
> 
> [...]
> 
>>> +static const struct of_device_id cpsw_of_mtable[] = {
>>> +    {
>>> +        .compatible    = "ti,am3352-cpsw",
>> I didn't notice this earlier, but can't you use the IP version
>> as a compatible instead of using a SOC name. Whats really SOC specific
>> on this IP ? Sorry i have missed any earlier discussion on this but
>> this approach doesn't seem good. Its like adding SOC checks in the
>> driver subsystem.
> 
> Hehe, welcome to the club!
> I keep arguing about that as well :-)
> 
> I think we should create a Facebook group: "against-the-soc-version-in-the-compatible-string".
> 
Indeed !!

Regards,
Santosh
