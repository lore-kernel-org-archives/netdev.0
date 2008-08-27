From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1: disable TSO by default
Date: Wed, 27 Aug 2008 05:37:32 -0400
Message-ID: <48B5205C.9000804@garzik.org>
References: <20080818192813.0d0dc1fd@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	link@miggy.org, ian@jeffray.co.uk, csnook@redhat.com,
	jie.yang@atheros.com, m@fhloston.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59100 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753147AbYH0Jhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:37:38 -0400
In-Reply-To: <20080818192813.0d0dc1fd@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> The atl1 driver is causing stalled connections and file corruption
> whenever TSO is enabled.  Two examples are here:
> 
> http://lkml.org/lkml/2008/7/15/325
> http://lkml.org/lkml/2008/8/18/543
> 
> Disable TSO by default until we can determine the source of the
> problem.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> cc: stable@kernel.org
> ---
> 
> Jeff, I've been trying to find the source of this problem in my
> spare time for a few weeks now, but haven't been successful.  We
> turned on TSO by default in 2.6.26 after fixing a nasty performance
> bug in it, but there's apparently another bug lurking.
> 
> This patch needs to be also applied to 2.6.26, hence the cc to
> stable.
> 
>  drivers/net/atlx/atl1.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)

applied


