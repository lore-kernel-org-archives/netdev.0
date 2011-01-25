From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: fix return value of couple of store functions
Date: Tue, 25 Jan 2011 13:07:06 -0800
Message-ID: <304.1295989626@death>
References: <20110125185315.GB2932@psychotron.redhat.com> <29198.1295983370@death> <20110125210324.GD2932@psychotron.redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:40504 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753860Ab1AYVHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 16:07:34 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0PKgZjU019053
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 15:43:55 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6714272809D
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 16:07:09 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0PL79Nl287800
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 16:07:09 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0PL78Qm000540
	for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 19:07:09 -0200
In-reply-to: <20110125210324.GD2932@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:

>count is incorrectly returned even in case of fail. Return ret instead.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 8fd0174..72bb0f6 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -1198,7 +1198,7 @@ static ssize_t bonding_store_carrier(struct device *d,
> 			bond->dev->name, new_value);
> 	}
> out:
>-	return count;
>+	return ret;
> }
> static DEVICE_ATTR(use_carrier, S_IRUGO | S_IWUSR,
> 		   bonding_show_carrier, bonding_store_carrier);
>@@ -1595,7 +1595,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
> 		}
> 	}
> out:
>-	return count;
>+	return ret;
> }
> static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
> 		   bonding_show_slaves_active, bonding_store_slaves_active);
