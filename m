From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rfc net] Allow the autoconfigured network interface to
 be renamed.
Date: Sun, 10 Jun 2012 20:25:15 -0700 (PDT)
Message-ID: <20120610.202515.138701034400919651.davem@davemloft.net>
References: <1339228087-14870-1-git-send-email-scott@scottnz.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scott.parlane@alliedtelesis.co.nz
To: scott@scottnz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373Ab2FKDZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 23:25:16 -0400
In-Reply-To: <1339228087-14870-1-git-send-email-scott@scottnz.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Parlane <scott@scottnz.com>
Date: Sat,  9 Jun 2012 19:48:07 +1200

> From: Scott Parlane <scott.parlane@alliedtelesis.co.nz>
> 
> if IP_PNP_RENAME_DEV is set, the first interface to be configured
> automatically by the kernel during boot will be renamed.
> 
> IP_PNP_DEV_NEWNAME is the name to give the autoconfigured device.
> 
> No changes will be made to any interface that is not autoconfigured.
> 
> This allows the assurance of the boot device name, without the need
> for an initramfs.
> 
> Signed-off-by: Scott Parlane <scott.parlane@alliedtelesis.co.nz>

Making this a compile time option makes absolutely no sense at all.

Assuming this feature is desirable at all (which is a big IF), it
should be a kernel command line option.
