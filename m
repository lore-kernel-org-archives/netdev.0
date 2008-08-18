From: Christof Schmitt <christof.schmitt@de.ibm.com>
Subject: Re: [PATCH] Remove duplicated unlikely() in IS_ERR()
Date: Mon, 18 Aug 2008 11:21:05 -0400
Message-ID: <20080818152105.GA8883@schmichrtp.de.ibm.com>
References: <48A52D69.1040501@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dedekind@infradead.org, yoshfuji@linux-ipv6.org,
	linux-mtd@lists.infradead.org, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: Hirofumi Nakagawa <hnakagawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:2277 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbYHRPV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 11:21:27 -0400
Content-Disposition: inline
In-Reply-To: <48A52D69.1040501@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 04:16:57PM +0900, Hirofumi Nakagawa wrote:
> Hi
> Some drivers have duplicated unlikely() macros.
> IS_ERR() already has unlikely() in itself.
> This patch cleans up such pointless codes although there is no real
> effect on the kernel's behaviour.
> 
> Thanks,
> Hirofumi Nakagawa
> 
> Signed-off-by: Hirofumi Nakagawa <hnakagawa@miraclelinux.com>
> ---
>  drivers/s390/scsi/zfcp_fsf.c |   32 ++++++++++++++++----------------
>  fs/ubifs/find.c              |    4 ++--
>  fs/ubifs/gc.c                |    8 ++++----
>  fs/ubifs/tnc.c               |    4 ++--
>  fs/ubifs/xattr.c             |    2 +-
>  net/ipv6/af_inet6.c          |    2 +-
>  6 files changed, 26 insertions(+), 26 deletions(-)

Thanks for spotting and fixing this. Could you split the zfcp changes
in a seperate patch? I will pick up the zfcp patch for a series of
fixes that i have pending here.

Christof
