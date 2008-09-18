From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: [PATCH] phylib: phy_mii_ioctl() fixes
Date: Thu, 18 Sep 2008 17:54:18 -0500
Message-ID: <2acbd3e40809181554r3d86d368jbc906142387c489@mail.gmail.com>
References: <20080918130652.GA10552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:6598 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755271AbYIRWyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 18:54:18 -0400
Received: by wf-out-1314.google.com with SMTP id 27so169002wfd.4
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 15:54:18 -0700 (PDT)
In-Reply-To: <20080918130652.GA10552@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2008 at 8:06 AM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> Make the SIOCGMIIPHY case fall through properly (it is supposed
> to not only return the ID of the default PHY but also to read from
> that PHY), and make phy_mii_ioctl() return the same error code as
> generic_mii_ioctl() in case of an unsupported operation.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Andy Fleming <afleming@freescale.com>
