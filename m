From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH v4 2/5] net: ethernet: cpsw: add optional third memory
 region for CONTROL module
Date: Fri, 23 Aug 2013 18:21:01 +0200
Message-ID: <52178BED.1070308@gmail.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-3-git-send-email-zonque@gmail.com> <521778DB.7040402@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:34862 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728Ab3HWQVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 12:21:05 -0400
In-Reply-To: <521778DB.7040402@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.08.2013 16:59, Sergei Shtylyov wrote:
> On 23-08-2013 18:16, Daniel Mack wrote:

>> +	priv->gmii_sel_reg = devm_ioremap_resource(&pdev->dev, res);
>> +	if (IS_ERR(priv->gmii_sel_reg)) {
>> +		dev_err(priv->dev, "unable to map control i/o region\n");
> 
>     You didn't actually seem to heed my words about error message.

Well yes I did, but only in the check for platform_get_resource(). As
the comment says - we pass on if that memory region is not given, but if
it is given, it also has to be valid.

> And don't  you want to do:
> 
> 	res = PTR_ERR(priv->gmii_sel_reg);


Erm, of course. Sorry for that.


Daniel
