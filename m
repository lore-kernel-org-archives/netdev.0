From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 18:30:24 +0200
Message-ID: <52178E20.5040404@gmail.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-4-git-send-email-zonque@gmail.com> <52177052.1030308@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:49342 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386Ab3HWQa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 12:30:27 -0400
In-Reply-To: <52177052.1030308@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.08.2013 16:23, Santosh Shilimkar wrote:
> On Friday 23 August 2013 10:16 AM, Daniel Mack wrote:

>> +static const struct of_device_id cpsw_of_mtable[] = {
>> +	{
>> +		.compatible	= "ti,am3352-cpsw",
>
> I didn't notice this earlier, but can't you use the IP version
> as a compatible instead of using a SOC name. Whats really SOC specific
> on this IP ? Sorry i have missed any earlier discussion on this but
> this approach doesn't seem good. Its like adding SOC checks in the
> driver subsystem.

As I already mentioned in the cover letter and in the commit message, I
just don't know which criteria makes most sense here.

On a general note, I would say that chances that this exactly IP core
with the same version number will appear on some other silicon which
doesn't support the control mode register in an AM33xx fashion, is not
necessarily negligible.

So what that new compatible string denotes is the cpsw in a version as
found on am3352 SoCs, which is actually exactly what it does.

I don't have a strong opinion here, but see your point. I just don't
have a better idea on how to treat that.


Daniel
