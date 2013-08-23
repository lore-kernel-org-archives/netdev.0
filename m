From: Benoit Cousson <bcousson@baylibre.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 17:22:17 +0200
Message-ID: <52177E29.6040103@baylibre.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-4-git-send-email-zonque@gmail.com> <52177052.1030308@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <zonque@gmail.com>, netdev@vger.kernel.org,
	nsekhar@ti.com, sergei.shtylyov@cogentembedded.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:49823 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289Ab3HWPWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 11:22:21 -0400
Received: by mail-we0-f169.google.com with SMTP id t61so697293wes.28
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 08:22:20 -0700 (PDT)
In-Reply-To: <52177052.1030308@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Santosh,

[...]

>> +static const struct of_device_id cpsw_of_mtable[] = {
>> +	{
>> +		.compatible	= "ti,am3352-cpsw",
> I didn't notice this earlier, but can't you use the IP version
> as a compatible instead of using a SOC name. Whats really SOC specific
> on this IP ? Sorry i have missed any earlier discussion on this but
> this approach doesn't seem good. Its like adding SOC checks in the
> driver subsystem.

Hehe, welcome to the club!
I keep arguing about that as well :-)

I think we should create a Facebook group: 
"against-the-soc-version-in-the-compatible-string".

Regards,
Benoit
