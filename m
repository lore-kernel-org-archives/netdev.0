From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Patch to latest iproute to get it to compile on FC5
Date: Wed, 13 Feb 2008 11:56:59 -0800
Message-ID: <20080213115659.4b8eb493@extreme>
References: <47B345D0.1020707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34664 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754786AbYBMT5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 14:57:10 -0500
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

No. please don't change the configure script.
And the linux/if.h comes from kernel stripped headers so it should
not get crufted up by ifdef's.

Short term fix is to include stripped hdlc header if needed.
Long fix is to get rid of hdlc dependency if possible.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
