From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 01/02] ixgb: eliminate checkstack warnings
Date: Fri, 23 Sep 2011 10:59:25 -0700
Message-ID: <1316800766.28330.3.camel@Joe-Laptop>
References: <1316779890-32436-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38602 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750724Ab1IWR70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 13:59:26 -0400
In-Reply-To: <1316779890-32436-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-23 at 05:11 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Really trivial fix, use kmalloc/kfree instead of stack space.
> use static const instead of const to further reduce stack usage.
> 
> V2: reflect changes suggested by Joe Perches

This is a less than complete commit log as
the patch also converts a local #define
of IXGB_ETH_LENGTH_OF_ADDRESS to ETH_ALEN
