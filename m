From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] irda: Convert IRDA_DEBUG to pr_debug
Date: Wed, 12 Nov 2014 16:56:12 -0800
Message-ID: <1415840172.4269.1.camel@perches.com>
References: <20141111.162257.701721486580745428.davem@davemloft.net>
	 <1415741850.16070.13.camel@perches.com>
	 <1415745897.16070.15.camel@perches.com>
	 <20141112.135719.707307878615480184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0073.hostedemail.com ([216.40.44.73]:54315 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752462AbaKMA4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 19:56:16 -0500
In-Reply-To: <20141112.135719.707307878615480184.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-12 at 13:57 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 11 Nov 2014 14:44:57 -0800
> > Use the normal kernel debugging mechanism which also
> > enables dynamic_debug at the same time.
> Applied to net-next, thanks Joe.

Apologies.

There was obviously insufficient platform and
config option testing on this patch.

David, can you lease revert and I'll work out the
various platform options defects that have been
reported by Fengguang's kbuild test robot.
