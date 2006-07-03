From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: Take lowlevel driver's channel change time into
 account during scanning.
Date: Mon, 3 Jul 2006 13:58:22 +0200
Message-ID: <20060703135822.123c2d9f@griffin.suse.cz>
References: <44A6DDC6.1040005@kpnplanet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkmaline@cc.hut.fi, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:12707 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750863AbWGCL6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 07:58:23 -0400
To: Gertjan van Wingerde <gwingerde@kpnplanet.nl>
In-Reply-To: <44A6DDC6.1040005@kpnplanet.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 01 Jul 2006 22:40:38 +0200, Gertjan van Wingerde wrote:
> Make the dscape stack take the driver-supplied channel change time into 
> account when actively scanning for networks.
> This particularly has been a problem in the rt2x00 driver, where 
> configuration changes are done via a work-queue, and
> the subsequent channel changes failed due to the dscape stack scheduling 
> a channel update while the previous one had not
> been performed yet, resulting in failed scans.

Your mail client converts tabs to spaces. Nevertheless, I applied the
patch to my git tree.

Thanks for fixing this,

 Jiri

-- 
Jiri Benc
SUSE Labs
