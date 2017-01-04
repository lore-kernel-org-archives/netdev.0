From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: usb: asix_devices: add .reset_resume for USB
 PM
Date: Wed, 04 Jan 2017 13:03:31 -0500 (EST)
Message-ID: <20170104.130331.1287004753446276933.davem@davemloft.net>
References: <1483435340-20371-1-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.foss@collabora.com, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: peter.chen@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58274 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934485AbdADSDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:03:39 -0500
In-Reply-To: <1483435340-20371-1-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chen <peter.chen@nxp.com>
Date: Tue, 3 Jan 2017 17:22:20 +0800

> The USB core may call reset_resume when it fails to resume asix device.
> And USB core can recovery this abnormal resume at low level driver,
> the same .resume at asix driver can work too. Add .reset_resume can
> avoid disconnecting after backing from system resume, and NFS can
> still be mounted after this commit.
> 
> Signed-off-by: Peter Chen <peter.chen@nxp.com>

Applied, thank you.
