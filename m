From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/13] tg3: Fix nvram selftest failures
Date: Mon, 12 Nov 2007 21:11:10 -0800 (PST)
Message-ID: <20071112.211110.84527235.davem@davemloft.net>
References: <1194655129.5745.267.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751137AbXKMFLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:11:11 -0500
In-Reply-To: <1194655129.5745.267.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:49 -0800

> Newer devices contain bootcode in the chip's private ROM area.  This
> bootcode is called selfboot.  Selfboot can be patched in the device's
> NVRAM and the patches can have several formats.  In one particular
> format, the checksum calculation needs to be slightly modified.  This
> patch adjusts the NVRAM test code for that case, and add support for the
> missing formats.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Matt.
