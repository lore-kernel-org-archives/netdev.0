From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] SIS900 show warning if bogus MAC address (take 2)
Date: Tue, 13 Jan 2009 11:06:21 -0800
Message-ID: <20090113110621.1456a2a8@extreme>
References: <20090113181821.GA21342@milesteg.arr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	venza@brownhat.org
To: Daniele Venzano <venza@brownhat.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44392 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207AbZAMTGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 14:06:25 -0500
In-Reply-To: <20090113181821.GA21342@milesteg.arr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jan 2009 19:18:21 +0100
Daniele Venzano <venza@brownhat.org> wrote:

> The attached patch modifies the sis900 driver when the MAC address
> read from the hardware is invalid. As suggested, the patch now
> generates a random address so that the user can go on and use
> the hardware. In any case a message is also shown to warn on the
> unexpected condition.
> This seems to happen with newer HW implementation of the sis900
> chipset, since this never came up before.
> 
> Patch is against vanilla 2.6.28 (but the driver doesn't change so often,
> so it will probably apply to older/newer versions too).
> 
> See bugzilla ID 10201 and 11649 and ignore the previous patch.
> 
> Signed-off-by: Daniele Venzano <venza@brownhat.org>
> 
> --
> Daniele Venzano
> http://www.brownhat.org
> 

It would be good if this driver was converted from using dev_name (ie pci_name()) 
and used the standard routines which print that and more: dev_err, dev_warn, dev_dbg, etc?
