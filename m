From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2 1/2] bonding: generic netlink infrastructure
Date: Thu, 16 Dec 2010 15:12:07 -0800
Message-ID: <20101216151207.3ead4c21@nehalam>
References: <1292540003-9465-1-git-send-email-fubar@us.ibm.com>
	<1292540003-9465-2-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49452 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817Ab0LPXMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 18:12:10 -0500
In-Reply-To: <1292540003-9465-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Dec 2010 14:53:22 -0800
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Generic netlink infrastructure for bonding.  Includes two
> netlink operations: notification for slave link state change, and a
> "get mode" netlink command.
> ---

1. The printk() for error needs to either be dropped or turned into
   a real loggable message (ie add more info and printk level).

2. Don't use C99 comments to comment out stuff

3. checkpatch has other whitespace complaints.

4. Missing Signed-off-by:





-- 
