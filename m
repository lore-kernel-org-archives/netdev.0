From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/10] GRETH: added option to disable a device node
 from bootloader.
Date: Thu, 13 Jan 2011 22:12:38 -0800 (PST)
Message-ID: <20110113.221238.97339127.davem@davemloft.net>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
	<1294907135-24884-2-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: daniel@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752094Ab1ANGMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 01:12:05 -0500
In-Reply-To: <1294907135-24884-2-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Thu, 13 Jan 2011 09:25:27 +0100

> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>

This is not how you do this.

Simply not present the device in the OpenFirmware tree at all.  If you
can make this special properly appear, you can also toss the device
node away completely.

There is zero reason whatsoever to create a special hack-job
non-standardized device node properly to do this.
