From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Patch to latest iproute to get it to compile on FC5
Date: Wed, 13 Feb 2008 12:34:02 -0800
Message-ID: <20080213123402.43cdbd45@extreme>
References: <47B345D0.1020707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59464 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758763AbYBMUeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 15:34:12 -0500
In-Reply-To: <47B345D0.1020707@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 11:32:32 -0800
Ben Greear <greearb@candelatech.com> wrote:

> I notice that the latest snapshot and git repository for iproute
> will not compile on FC5 due to not finding __constant_hton* symbols
> and a lack of the hdlc/ioctl.h file on FC5.
> 
> I am attaching a patch that appears to fix the problems for me.
> 
> Please consider applying this or something similar.
> 
> Signed-off-by:  Ben Greear <greearb@candelatech.com>
> 
> 
> Thanks,
> Ben
> 

I added include/linux/hdlc/ioctl.h to the santized headers in the
current git.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
