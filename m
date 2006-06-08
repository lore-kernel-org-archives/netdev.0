From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] PHYLIB/gianfar: Use phy_ethtool_get_link()	for	get_link
 op
Date: Thu, 08 Jun 2006 11:33:55 -0400
Message-ID: <44884363.6080907@garzik.org>
References: <1149551334.10700.48.camel@localhost.localdomain>	 <44883B0E.5090802@garzik.org> <1149779939.30343.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56782 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964877AbWFHPd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 11:33:59 -0400
To: Nathaniel Case <ncase@xes-inc.com>
In-Reply-To: <1149779939.30343.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nathaniel Case wrote:
> On Thu, 2006-06-08 at 10:58 -0400, Jeff Garzik wrote:
>>> +static u32 gfar_get_link(struct net_device *dev)
>>> +{
>>> +	struct gfar_private *priv = netdev_priv(dev);
>>> +	struct phy_device *phydev = priv->phydev;
>>> +
>>> +	if (NULL == phydev)
>>> +		return -ENODEV;
>> NAK, return code obviously wrong
> 
> Thanks.  I think we can just return 0 for that case.  Updated patch
> follows.
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>

Sigh.  See rule #6: http://linux.yyz.us/patch-format.html

You excised the patch description, which means your patch can no longer 
be applied correctly by scripts.

	Jeff


