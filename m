From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 2/2] smsc95xx: support PHY wakeup source
Date: Thu, 22 Nov 2012 12:03:44 +0000
Message-ID: <CAKh2mn79sEKVRUe-QGLNv2Jqfuj0eS9PVwrcLiTp7zJxmA1T8A@mail.gmail.com>
References: <1353504577-5719-1-git-send-email-steve.glendinning@shawell.net>
	<1353504577-5719-2-git-send-email-steve.glendinning@shawell.net>
	<20121121.120721.1391625922017753607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:57838 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965062Ab2KVTSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 14:18:13 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so3322172eaa.19
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 11:18:12 -0800 (PST)
In-Reply-To: <20121121.120721.1391625922017753607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +{
>> +     struct mii_if_info *mii = &dev->mii;
>> +
>> +        /* first, a dummy read, needed to latch some MII phys */
>> +     int ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);
>
> Please keep the local variable declarations together at the beginning
> of the basic block, don't intermix empty lines and comments as you
> are doing here.

Thanks David, please drop these two patches.  I'll fix these points up
and re-submit.
