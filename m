From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next-2.6 2/3] netdev: Make
 ethtool_ops::set_flags() return -EINVAL for unsupported flags
Date: Wed, 30 Jun 2010 18:01:37 +0300
Message-ID: <1277910097.28932.22.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
 <1277902016.2082.12.camel@achroite.uk.solarflarecom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3588 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753691Ab0F3PC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 11:02:26 -0400
In-Reply-To: <1277902016.2082.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 05:46 -0700, Ben Hutchings wrote:
> The documented error code for attempts to set unsupported flags (or
> to clear flags that cannot be disabled) is EINVAL, not EOPNOTSUPP.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

If that's what the document say...
Acked-by: Eilon Greenstein <eilong@broadcom.com>

Thanks Ben!



