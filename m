From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] atm: firestream: remove duplicate define
Date: Mon, 21 Oct 2013 07:53:35 -0400
Message-ID: <20131021075335.5c9e4490@thirdoffive.cmf.nrl.navy.mil>
References: <1382343161-3243-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:58665 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab3JUMIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 08:08:53 -0400
In-Reply-To: <1382343161-3243-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>

On Mon, 21 Oct 2013 10:12:41 +0200
Michael Opdenacker <michael.opdenacker@free-electrons.com> wrote:

> This patch removes a duplicate define in drivers/atm/firestream.h
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
> ---
>  drivers/atm/firestream.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/atm/firestream.h b/drivers/atm/firestream.h
> index 49e783e..364eded 100644
> --- a/drivers/atm/firestream.h
> +++ b/drivers/atm/firestream.h
> @@ -420,7 +420,6 @@ struct fs_transmit_config {
>  #define RC_FLAGS_BFPS_BFP27 (0xd << 17)
>  #define RC_FLAGS_BFPS_BFP47 (0xe << 17)
>  
> -#define RC_FLAGS_BFPS       (0x1 << 17)
>  #define RC_FLAGS_BFPP       (0x1 << 21)
>  #define RC_FLAGS_TEVC       (0x1 << 22)
>  #define RC_FLAGS_TEP        (0x1 << 23)
