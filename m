From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] iproute2:  Fix filtering related to flushing IP
 addresses.
Date: Mon, 23 Aug 2010 08:15:28 -0700
Message-ID: <20100823081528.46bc001e@nehalam>
References: <1281978008-6383-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60206 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753975Ab0HWPPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 11:15:30 -0400
In-Reply-To: <1281978008-6383-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Aug 2010 10:00:08 -0700
Ben Greear <greearb@candelatech.com> wrote:

> The old 'ip addr flush' logic had several flaws:
> 
> * It reversed logic for primary v/s secondary flags
>   (though, it sort of worked right anyway)
> 
> * The code tried to remove secondaries and then primaries,
>   but in practice, it always removed one primary per loop,
>   which not at all efficient.
> 
> * The filter logic in the core would run only the first
>   filter in most cases.
> 
> * If you used '-s -s', the ifa_flags member would be
>   modified, which could make future filters fail
>   to function fine.
> 
> This patch attempts to fix all of these issues.
> 
> Tested-by: Brian Haley <brian.haley@hp.com>
> Signed-off-by: Ben Greear <greearb@candelatech.com>

applied

-- 
