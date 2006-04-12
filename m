From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] acxsm: Reduce the number of ACX_PACKED instructions
Date: Wed, 12 Apr 2006 16:58:01 -0400
Message-ID: <20060412205756.GD12788@tuxdriver.com>
References: <11433168763687-git-send-email-carlos@cmartin.tk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:56328 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932144AbWDLU6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 16:58:33 -0400
To: Carlos Martin <carlos@cmartin.tk>
Content-Disposition: inline
In-Reply-To: <11433168763687-git-send-email-carlos@cmartin.tk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 25, 2006 at 09:01:16PM +0100, Carlos Martin wrote:
> Up to now, we were using ACX_PACKED after every field. I've finally
> found out how to use only one at the end of each struct whilst
> maintaining the typedef where it is now.
> 
> This should also apply to acx with a bit of fuzz, but I consider it to
> be in maintenance mode, so this doesn't qualify for it.
> 
> Signed-off-by: Carlos Martin <carlos@cmartin.tk>
> 
> ---
> 
>  acx_struct.h |  874 +++++++++++++++++++++++++++++-----------------------------
>  common.c     |   26 +-
>  ioctl.c      |   10 -
>  usb.c        |    8 -
>  4 files changed, 457 insertions(+), 461 deletions(-)
> 
> 5fb2fdfd8c028a40921bbf9ef7ec4c53c03fcab4
> diff --git a/acx_struct.h b/acx_struct.h

Denis, have you got this patch?  Or do I need to apply it?

Carlos, please make your diffs from the root of the kernel tree.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
