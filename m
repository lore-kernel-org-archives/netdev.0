From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH RFC] net/core: API to create/destroy /sys/class/net
 entries
Date: Wed, 16 Apr 2008 18:12:00 -0700
Message-ID: <20080416181200.2b84ef5a@extreme>
References: <14079.1208394386@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59369 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762211AbYDQBME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 21:12:04 -0400
In-Reply-To: <14079.1208394386@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Apr 2008 18:06:26 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> 
> 	Some background: 
> 
> 	Bonding creates a file in sysfs, /sys/class/net/bonding_masters,

That is a problem because it confuses scripts that use /sys/class/net/X
to find a list of network devices. I.e. that was a bad API choice.
