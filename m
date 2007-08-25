From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] fix realtek phy id in forcedeth
Date: Sat, 25 Aug 2007 00:01:47 -0400
Message-ID: <46CFA9AB.6060506@garzik.org>
References: <20070822083844.%N@1wt.eu> <20070822204225.GD14132@1wt.eu> <20070822230526.GC32121@suse.de> <200708231750.45257.prakash@punnoor.de> <20070823165513.GA6341@kroah.com> <20070823192709.GA22729@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Prakash Punnoor <prakash@punnoor.de>, Greg KH <gregkh@suse.de>,
	stable@kernel.org, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	linux-kernel@vger.kernel.org, Chuck Ebbert <cebbert@redhat.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50823 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbXHYEBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:01:54 -0400
In-Reply-To: <20070823192709.GA22729@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Willy Tarreau wrote:
> Hi Greg,
> 
> On Thu, Aug 23, 2007 at 09:55:13AM -0700, Greg KH wrote:
>> It might help if someone sends a real patch that can be applied :)
> 
> This is getting really silly now :-) We're all wasting more time
> wondering who will send the patch than posting it. I've lost, I got
> fed up first, so here it is. Please apply to mainline then stable.
> 
> Thanks,
> Willy
> 
> --
> 
>>From a0e2922b99eedd9863232368ea2afe072c52783e Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 23 Aug 2007 21:35:41 +0200
> Subject: [PATCH] fix realtek phy id in forcedeth
> 
> As noticed by Chuck Ebbert, commit c5e3ae8823693b260ce1f217adca8add1bc0b3de
> introduced a copy-paste typo, as realtek phy is 0x732 and not 0x1c1. Obvious
> fix below suggested by Ayaz Abdulla.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Chuck Ebbert <cebbert@redhat.com>
> ---
>  drivers/net/forcedeth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied


