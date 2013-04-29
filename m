From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 net-next 2/2] bridge: Add a flag to control unicast
 packet flood.
Date: Mon, 29 Apr 2013 16:43:50 -0700
Message-ID: <20130429164350.11eaaab1@nehalam.linuxnetplumber.net>
References: <1367256945-25923-1-git-send-email-vyasevic@redhat.com>
	<1367256945-25923-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:51730 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932552Ab3D2XoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 19:44:02 -0400
Received: by mail-pa0-f44.google.com with SMTP id rl6so15605pac.31
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 16:44:01 -0700 (PDT)
In-Reply-To: <1367256945-25923-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Apr 2013 13:35:45 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> Add a flag to control flood of unicast traffic.  By default, flood is
> on and the bridge will flood unicast traffic if it doesn't know
> the destination.  When the flag is turned off, unicast traffic
> without an FDB will not be forwarded to the specified port.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> Reviewed-by: Michael S. Tsirkin <mst@redhat.com>
> 

This a good idea and thank you for doing it. I like that the flag is expressed
as a positive value (rather than an inverse value like no-flood).

The name BR_UNICAST_FLOOD is too long, just use BR_FLOOD and keep the code
shorter.

This doesn't apply against current net-next (same problem as first patch).

Also, I am not a fan of having lots of boolean flag variables in normal
code paths. It ends up reading like PASCAL code. But probably unavoidable in this case.
