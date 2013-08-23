From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 2/5] net: ethernet: cpsw: add optional third memory
 region for CONTROL module
Date: Fri, 23 Aug 2013 21:37:20 +0400
Message-ID: <52179DD0.4010300@cogentembedded.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-3-git-send-email-zonque@gmail.com> <521778DB.7040402@cogentembedded.com> <52178BED.1070308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:39853 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505Ab3HWRhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 13:37:15 -0400
Received: by mail-lb0-f169.google.com with SMTP id u10so724835lbi.28
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 10:37:13 -0700 (PDT)
In-Reply-To: <52178BED.1070308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2013 08:21 PM, Daniel Mack wrote:

>>> +	priv->gmii_sel_reg = devm_ioremap_resource(&pdev->dev, res);
>>> +	if (IS_ERR(priv->gmii_sel_reg)) {
>>> +		dev_err(priv->dev, "unable to map control i/o region\n");

>>      You didn't actually seem to heed my words about error message.

> Well yes I did, but only in the check for platform_get_resource(). As
> the comment says - we pass on if that memory region is not given, but if
> it is given, it also has to be valid.

    Yes, but what I told you was devm_ioremap_resource() prints the error 
messages itself, so that you don't have to. And you even consented with that. :-)

>> And don't  you want to do:

>> 	res = PTR_ERR(priv->gmii_sel_reg);

     Well, I've messed with the variable name: 'res' is struct resource *', 
what I meant was *int* variable.

> Erm, of course. Sorry for that.

> Daniel

WBR, Sergei
