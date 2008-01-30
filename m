From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 6/7][BNX2]: Update firmware.
Date: Tue, 29 Jan 2008 18:29:56 -0800
Message-ID: <1201660196.19087.29.camel@dell>
References: <1201652420.19087.15.camel@dell>
 <20080129234615.GB25253@stro.at>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>
To: "maximilian attems" <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4256 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbYA3Btb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 20:49:31 -0500
In-Reply-To: <20080129234615.GB25253@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-01-30 at 00:46 +0100, maximilian attems wrote:

> happily omitted diffstat:
>  drivers/net/bnx2_fw.h  | 1499 +++++++++++++++++++--------------------
>  drivers/net/bnx2_fw2.h |  464 ++++++------
>  2 files changed, 982 insertions(+), 981 deletions(-)
> 
> 
> when can bnx2 grow up to proper request_firmware() usage?
> 

Didn't we beat this topic to death last time?

Once again, the driver is tightly coupled with the firmware.  We don't
want things to break when users upgrade or downgrade the kernel.  Coding
the driver to deal with different firmware versions will add a lot of
complexity.

